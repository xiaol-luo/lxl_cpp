
LoginGameMgr = LoginGameMgr or class("LoginGameMgr", ServiceLogic)

function LoginGameMgr:ctor(logic_mgr, logic_name)
    LoginGameMgr.super.ctor(self, logic_mgr, logic_name)
    self.login_items = {}
    self.client_cnn_mgr = self.service.client_cnn_mgr
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

function LoginGameMgr:_on_tick()

end

function LoginGameMgr:process_req_login_game(netid, pid, msg)
    log_debug("LoginGameMgr.process_req_login_game %s %s", pid, msg)
    --[[
    self.client_cnn_mgr:send(netid, ProtoId.rsp_login_game, {
        error_code=0, auth_sn="", timestamp=logic_sec()
    })
    ]]

    local ERROR_NOT_LOGIN_ITEM = 1
    local ERROR_START_CO_FAIL = 2
    local ERROR_AUTH_LOGIN_FAIL = 3
    local ERROR_COROUTINE_RAISE_ERROR = 4

    local login_item = self.login_items[netid]
    if not login_item then
        self.client_cnn_mgr:send(netid, ProtoId.rsp_login_game, {error_code=ERROR_NOT_LOGIN_ITEM})
        return
    end

    local over_cb = function(co)
        local error_code = 0
        local auth_sn, timestamp = nil, nil
        local return_vals = co:get_return_vals()
        if not return_vals then
            error_code = ERROR_COROUTINE_RAISE_ERROR
            log_debug("process_req_login_game coroutine raise error: %s", co:get_error_msg())
        else
            error_code, auth_sn, timestamp = table.unpack(return_vals)
        end
        self.client_cnn_mgr:send(netid, ProtoId.rsp_login_game, { error_code=error_code, auth_sn=auth_sn, timestamp=timestamp })
    end
    local main_logic = function(co, msg)
        local auth_params = {
            token = msg.token,
            timestamp = msg.timestamp,
        }
        log_debug("main_logic 1")
        local auth_param_strs = {}
        for k, v in pairs(auth_params) do
            table.insert(auth_param_strs, string.format("%s=%s", k, v))
        end
        log_debug("main_logic 11")
        local auth_cfg = self.service.all_service_cfg:get_third_party_service(Service_Const.Auth_Service, Service_Const.For_Test)
        log_debug("main_logic 12")
        local host = string.format("%s:%s", auth_cfg[Service_Const.Ip], auth_cfg[Service_Const.Port])
        log_debug("main_logic 13")
        local url = string.format("%s/%s?%s", host, "login_auth", table.concat(auth_param_strs, "&"))
        log_debug("main_logic 14")
        log_debug("url = %s", url)
        local co_ok, id_int64, rsp_state, heads_map, body_str = HttpClient.co_get(url, {})
        log_debug("login_auth body_str %s %s",rsp_state,  body_str)
        if not co_ok or "OK" ~= rsp_state then
            log_debug("main_logic 2")
            return ERROR_AUTH_LOGIN_FAIL
        end

        local auth_login_ret = rapidjson.decode(body_str)
        log_debug("auth_login_ret %s", auth_login_ret)
        return 0, auth_login_ret.token, auth_login_ret.timestamp
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