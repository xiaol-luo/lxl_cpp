
---@class GateForwardMsg:LogicEntity
GateForwardMsg = GateForwardMsg or class("GateForwardMsg", LogicEntity)

function GateForwardMsg:ctor(logic_svc, logic_name)
    GateForwardMsg.super.ctor(self, logic_svc, logic_name)
    ---@type GateClientMgr
    self._gate_client_mgr = nil
end


function GateForwardMsg:_on_init()
    GateForwardMsg.super._on_init(self)
    self._gate_client_mgr = self.logic_svc.gate_client_mgr
end

function GateForwardMsg:_on_start()
    GateForwardMsg.super._on_start(self)
    self._gate_client_mgr:set_msg_handler(Forward_Msg_Pid.req_forward_game_msg,
            Functional.make_closure(self._on_msg_forward_game_msg, self))
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.gate.method.forward_msg_to_client,
            Functional.make_closure(self._handle_remote_call_forward_msg_to_client, self))
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.gate.method.forward_binary_to_client,
            Functional.make_closure(self._handle_remote_call_forward_binary_to_client, self))
end

function GateForwardMsg:_on_stop()
    GateForwardMsg.super._on_stop(self)
    self._gate_client_mgr:set_msg_handler(Login_Pid.req_user_login, nil)
end

function GateForwardMsg:_on_release()
    GateForwardMsg.super._on_release(self)
end

function GateForwardMsg:_on_update()

end

---@param gate_client GateClient
function GateForwardMsg:_on_msg_forward_game_msg(gate_client, pid, msg)
    if not gate_client:is_in_game() or not gate_client.game_server_key or not gate_client.role_id then
        return
    end
    self._rpc_svc_proxy:call(nil, gate_client.game_server_key, Rpc.game.method.forward_msg_to_game, gate_client.netid, gate_client.role_id, msg.msg)
end

---@param rpc_rsp RpcRsp
function GateForwardMsg:_handle_remote_call_forward_msg_to_client(rpc_rsp, gate_netid, pid, msg)
    rpc_rsp:response()
    local gate_client = self._gate_client_mgr:get_client(gate_netid)
    if gate_client then
        gate_client:send_msg(pid, msg)
    end
end

function GateForwardMsg:_handle_remote_call_forward_binary_to_client(rpc_rsp, gate_netid, pid, bytes)
    rpc_rsp:response()
    local gate_client = self._gate_client_mgr:get_client(gate_netid)
    if gate_client then
        gate_client:send_bin(pid, bytes)
    end
end


