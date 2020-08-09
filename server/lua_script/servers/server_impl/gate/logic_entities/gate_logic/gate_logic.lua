
---@class GateLogic:LogicEntity
GateLogic = GateLogic or class("GateLogic", LogicEntity)

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
    self._gate_client_mgr:set_msg_handler(Login_Pid.req_user_login, Functional.make_closure(self._on_msg_user_login, self))
end

function GateLogic:_on_stop()
    GateLogic.super._on_stop(self)
    self._gate_client_mgr:set_msg_handler(Login_Pid.req_user_login, nil)
end

function GateLogic:_on_release()
    GateLogic.super._on_release(self)
end

function GateLogic:_on_update()

end

---@param gate_client GateClient
function GateLogic:_on_msg_user_login(gate_client, pid, msg)
    -- todo: 定义错误码
    if Gate_Client_State.free ~= gate_client.state or gate_client.user_id then
        gate_client:send_msg(Login_Pid.rsp_user_login, { error_num = 1})
        gate_client:disconnect()
        return
    end
    if not self.server.discovery:is_cluster_can_work() then
        gate_client:send_msg(Login_Pid.rsp_user_login, { error_num = 2})
        gate_client:disconnect()
    end
    gate_client.user_id = msg.user_id
    gate_client.auth_sn = msg.auth_sn
    gate_client.state = Gate_Client_State.manage_role
    gate_client:send_msg(Login_Pid.rsp_user_login, { error_num = Error_None })
end


