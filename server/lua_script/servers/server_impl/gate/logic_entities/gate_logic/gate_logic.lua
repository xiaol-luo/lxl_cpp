
---@class GateLogic:GameLogicEntity
GateLogic = GateLogic or class("GateLogic", GameLogicEntity)

function GateLogic:ctor(logics, logic_name)
    GateLogic.super.ctor(self, logics, logic_name)
    ---@type GateClientMgr
    self._gate_client_mgr = nil
end


function GateLogic:_on_init()
    GateLogic.super._on_init(self)
    self._gate_client_mgr = self.logics.gate_client_mgr
end

function GateLogic:_on_start()
    GateLogic.super._on_start(self)
    self._gate_client_mgr:set_msg_handler(Login_Pid.req_login_gate, Functional.make_closure(self._on_msg_user_login, self))
end

function GateLogic:_on_stop()
    GateLogic.super._on_stop(self)
    self._gate_client_mgr:set_msg_handler(Login_Pid.req_login_gate, nil)
end

function GateLogic:_on_release()
    GateLogic.super._on_release(self)
end

function GateLogic:_on_update()

end

---@param gate_client GateClient
function GateLogic:_on_msg_user_login(gate_client, pid, msg)
    -- todo: 定义错误码
    self:try_login_gate(gate_client, msg, function(error_num)
        gate_client:send_msg(Login_Pid.rsp_login_gate, { error_num = error_num })
    end)
end


---@param cb_fn fun(error_num:number):void
function GateLogic:try_login_gate(gate_client, msg, cb_fn)
    if Gate_Client_State.free ~= gate_client.state or gate_client.user_id then
        gate_client:send_msg(Login_Pid.rsp_login_gate, { error_num = 1})
        gate_client:disconnect()
        return
    end
    if not self.server.discovery:is_cluster_can_work() then
        gate_client:send_msg(Login_Pid.rsp_login_gate, { error_num = 2})
        gate_client:disconnect()
    end
    gate_client.user_id = msg.user_id
    gate_client.auth_sn = msg.token
    gate_client.state = Gate_Client_State.authing
    gate_client.auth_data = {
        token = msg.token,
        token_timestamp = msg.token_timestamp,
        app_id = msg.app_id,
        auth_ip = msg.auth_ip,
        auth_port = msg.auth_port,
    }
    -- todo: 去auth_server鉴权
    local kv_tb = {}
    kv_tb["token"] = msg.token
    kv_tb["timestamp"] = msg.token_timestamp
    local query_params = {}
    for  k, v in pairs(kv_tb) do
        table.insert(query_params, string.format("%s=%s", k, v))
    end
    local query_url = string.format("http://%s:%s/verity_token?%s", msg.auth_ip, msg.auth_port, table.concat(query_params, "&"))
    HttpClient.get(query_url, Functional.make_closure(self._on_http_rsp_vertity_token, self, gate_client, cb_fn))
end


function GateLogic:_on_http_rsp_vertity_token(gate_client, cb_fn, http_ret)
    local error_num = Error_None
    if Http_OK == http_ret.state then
        local rsp_data = lua_json.decode(http_ret.body)
        if Error_None == rsp_data.error_num then
            if gate_client.user_id == rsp_data.user_id then
                -- error_num = Error_None
                if Gate_Client_State.authing ==  gate_client.state then
                    if self.server.discovery:is_cluster_can_work() then
                        gate_client.state = Gate_Client_State.manage_role
                    else
                        error_num = 5
                    end
                else
                    error_num = 4
                end
            else
                error_num = 3
            end
        else
            error_num = 2
        end
    else
        error_num = 1
    end
    if cb_fn then
        cb_fn(error_num)
    end
end


