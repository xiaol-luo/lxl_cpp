
LoginGameMgr = LoginGameMgr or class("LoginGameMgr", ServiceLogic)

function LoginGameMgr:ctor(logic_mgr, logic_name)
    LoginGameMgr.super.ctor(self, logic_mgr, logic_name)
    self.login_items = {}
    self.client_cnn_mgr = self.service.client_cnn_mgr
    self.gate_states = {}
    self.last_query_gate_state_sec = 0
    self.Query_Gate_State_Span_Sec = 5
    self.rpc_mgr = self.service.rpc_mgr
end

function LoginGameMgr:init()
    LoginGameMgr.super.init(self)
    self.timer_proxy = TimerProxy:new()
    self.client_cnn_mgr:set_process_fn(ProtoId.req_login_game, Functional.make_closure(self.process_req_login_game, self))
end

function LoginGameMgr:start()
    LoginGameMgr.super.start(self)
    self.timer_proxy:release_all()
    local Tick_Span_Ms = 2 * 1000
    self.timer_proxy:firm(Functional.make_closure(self._on_tick, self), Tick_Span_Ms, -1)
    self.event_proxy:subscribe(Client_Cnn_Event_New_Client, Functional.make_closure(self._on_new_cnn, self))
    self.event_proxy:subscribe(Client_Cnn_Event_Close_Client, Functional.make_closure(self._on_close_cnn, self))
end

function LoginGameMgr:stop()
    LoginGameMgr.super.stop(self)
    self.timer_proxy:release_all()
    self.event_proxy:release_all()
end

function LoginGameMgr:_on_new_cnn(netid, error_code)
    log_debug("LoginGameMgr._on_new_cnn")
    if 0 ~= error_code then
        return
    end
    local item = LoginGameItem:new()
    item.netid = netid
    item.state = LoginGameState.Free
    self.login_items[item.netid] = item
end

function LoginGameMgr:_on_close_cnn(netid, error_code)
    self.event_proxy:fire(Login_Game_Event_Stop_Login, netid)
    self.login_items[netid] = nil
end

function LoginGameMgr:CheckQueryGateStates()
    local now_sec = logic_sec()
    if now_sec >= self.last_query_gate_state_sec + self.Query_Gate_State_Span_Sec then
        self.last_query_gate_state_sec = now_sec
        local gate_infos = self.service.zone_net:get_service_group(Service_Const.Gate)
        for _, gate_info in pairs(gate_infos) do
            local gk = gate_info.key
            self.service.rpc_mgr:call(function(error_num, ret)
                log_debug("CheckQueryGateStates %s %s %s", gk, error_num, ret)
                if Rpc_Error.None ~= error_num then
                    self.gate_states[gk] = nil
                else
                    local gate_state = {
                        client_connect_ip = ret.client_connect_ip,
                        client_connect_port = ret.client_connect_port
                    }
                    self.gate_states[gk] = gate_state
                end
            end, gk, GateRpcFn.query_state)
        end
    end
end

function LoginGameMgr:_on_tick()
    self:CheckQueryGateStates()
end

function LoginGameMgr:process_req_login_game(netid, pid, msg)
    log_debug("LoginGameMgr.process_req_login_game %s %s", pid, msg)
    local ERROR_NOT_LOGIN_ITEM = 1
    local ERROR_START_CO_FAIL = 2
    local ERROR_AUTH_LOGIN_FAIL = 3
    local ERROR_COROUTINE_RAISE_ERROR = 4
    local ERROR_DB_ERROR = 5
    local ERROR_NO_GATE_AVAILABLE = 6

    local login_item = self.login_items[netid]
    if not login_item then
        self.client_cnn_mgr:send(netid, ProtoId.rsp_login_game, {error_code=ERROR_NOT_LOGIN_ITEM})
        return
    end
    if LoginGameState.Free ~= login_item.state then
        return
    end

    login_item.state = LoginGameState.Auth

    local over_cb = function(co)
        local error_code = 0
        local ret = {}
        local return_vals = co:get_return_vals()
        if not return_vals then
            error_code = ERROR_COROUTINE_RAISE_ERROR
            log_debug("process_req_login_game coroutine raise error: %s", co:get_error_msg())
        else
            error_code, ret = table.unpack(return_vals.vals, 1, return_vals.n)
        end
        log_debug("xxxxxxxxxxx %s", return_vals)
        ret = ret or {}
        self.client_cnn_mgr:send(netid, ProtoId.rsp_login_game, {
            error_code = error_code,
            auth_sn = ret.auth_sn,
            timestamp = ret.timestamp,
            app_id = ret.app_id,
            user_id = ret.user_id,
            gate_ip = ret.gate_ip,
            gate_port = ret.gate_port,
            auth_ip = ret.auth_ip,
            auth_port = ret.auth_port,
        })
    end
    local main_logic = function(co, msg)
        local auth_params = {
            token = msg.token,
            timestamp = msg.timestamp,
        }
        local auth_param_strs = {}
        for k, v in pairs(auth_params) do
            table.insert(auth_param_strs, string.format("%s=%s", k, v))
        end
        local auth_cfg = self.service.all_service_cfg:get_third_party_service(Service_Const.Auth_Service, Service_Const.For_Test)
        local host = string.format("%s:%s", auth_cfg[Service_Const.Ip], auth_cfg[Service_Const.Port])
        local url = string.format("%s/%s?%s", host, "login_auth", table.concat(auth_param_strs, "&"))
        local co_ok, http_ret = HttpClient.co_get(url, {})
        local rsp_state, body_str = http_ret.state, http_ret.body
        if not co_ok or "OK" ~= rsp_state then
            return ERROR_AUTH_LOGIN_FAIL
        end
        local auth_login_ret = rapidjson.decode(body_str)
        local account_id = auth_login_ret.uid
        local app_id = auth_login_ret.appid
        local db_client = self.service.db_client
        local query_db = self.service.query_db
        co_ok, db_ret = db_client:co_find_one(1, query_db, "account", { account_id=account_id })
        if not co_ok then
            return ERROR_COROUTINE_RAISE_ERROR
        end
        if 0 ~= db_ret.error_num then
            return ERROR_DB_ERROR
        end
        log_debug("co_find_one account_id:%s db_ret: %s", account_id, db_ret)
        local user_id = nil
        if db_ret.matched_count <= 0 then
            user_id = native.gen_uuid()
            -- 数据库里需要对account_id设置唯一限制
            co_ok, db_ret = db_client:co_insert_one(1, query_db, "account",
                    { account_id=account_id, user_id=user_id }
            )
            log_debug("co_insert_one db_ret: %s", db_ret)
            if not co_ok then
                return ERROR_COROUTINE_RAISE_ERROR
            end
            if 0 ~= db_ret.error_num or db_ret.inserted_count <= 0 then
                return ERROR_DB_ERROR
            end
        else
            user_id = db_ret.val["0"].user_id
        end

        local gk, gv = random.pick_one(self.gate_states)
        log_debug("random.pick_one(self.gate_states) %s %s", gk, gv)
        if not gv then
            return ERROR_NO_GATE_AVAILABLE
        end
        local gate_port = gv.client_connect_port
        local gate_ip = gv.client_connect_ip
        local return_val = {
            auth_sn = auth_login_ret.token,
            timestamp = auth_login_ret.timestamp,
            app_id = app_id,
            user_id = user_id,
            gate_ip = gate_ip,
            gate_port = gate_port,
            auth_ip = auth_cfg[Service_Const.Ip],
            auth_port = tonumber(auth_cfg[Service_Const.Port]),
        }
        return 0, return_val
    end
    local co = ex_coroutine_create(main_logic, over_cb)
    local start_ok = ex_coroutine_start(co, co, msg)
    if not start_ok then
        self.client_cnn_mgr:send(netid, ProtoId.rsp_login_game, {error_code=ERROR_START_CO_FAIL})
        return
    end
    local Expired_Ms = 15 * 1000
    -- ex_coroutine_expired(co, Expired_Ms)
end