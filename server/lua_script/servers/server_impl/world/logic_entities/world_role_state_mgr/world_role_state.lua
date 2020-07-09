
---@class WorldRoleState
---@field cached_rpc_rsp RpcRsp
WorldRoleState = WorldRoleState or class("WorldRoleState")

function WorldRoleState:ctor(mgr, gate_server_key, gate_netid, gate_auth_sn, user_id, role_id, session_id)
    self._mgr = mgr
    self.gate_server_key = gate_server_key
    self.gate_netid = gate_netid
    self.gate_auth_sn = gate_auth_sn
    self.user_id = user_id
    self.role_id = role_id
    self.session_id = session_id
    self.state = World_Role_State.inited
    self.cached_rpc_rsp = nil
    self.game_server_key = nil
    self.idle_begin_sec = nil
    self.release_try_times = nil
    self.release_opera_ids = nil
    self.release_begin_sec = nil
end





