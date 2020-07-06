
---@class GateLogic:LogicEntity
GateLogic = GateLogic or class("GateLogic", LogicEntity)

function GateLogic:ctor(logic_svc, logic_name)
    GateLogic.super.ctor(self, logic_svc, logic_name)
    ---@type GateClientMgr
    self._gate_client_mgr = nil
end


function GateLogic:_on_init()
    GateLogic.super._on_init(self)
    self._gate_client_mgr = self.logic_svc.gate_client_mgr
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
    -- log_print("GateLogic:_user_login ", msg)
    if gate_client.user_id then
        gate_client:send_msg(Login_Pid.rsp_user_login, { error_num = 1})
        gate_client:reset()
        return
    end
    gate_client.user_id = msg.user_id
    gate_client:send_msg(Login_Pid.rsp_user_login, { error_num = Error_None})
end


