
---@class GameRoleMgr:LogicEntity
GameRoleMgr = GameRoleMgr or class("GameRoleMgr", LogicEntity)

function GameRoleMgr:_on_init()
    GameRoleMgr.super._on_init(self)
    ---@type GameServer
    self.server = self.server
    self._online_world_shadow = self.server.online_world_shadow
end

function GameRoleMgr:_on_start()
    GameRoleMgr.super._on_start(self)

    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.game.method.launch_role, Functional.make_closure(self._handle_remote_call_launch_role, self))
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.game.method.change_gate_client, Functional.make_closure(self._handle_remote_call_change_gate_client, self))
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.game.method.release_role, Functional.make_closure(self._handle_remote_call_release_role, self))
end

function GameRoleMgr:_on_stop()
    GameRoleMgr.super._on_stop(self)
end

function GameRoleMgr:_on_release()
    GameRoleMgr.super._on_release(self)
end

function GameRoleMgr:_on_update()    -- log_print("GameRoleMgr:_on_update")
end

---@param rpc_rsp RpcRsp
function GameRoleMgr:_handle_remote_call_launch_role(rpc_rsp, netid, auth_sn, user_id, role_id)
    log_print("GameRoleMgr:_handle_remote_call_launch_role", netid, auth_sn, user_id, role_id)
    rpc_rsp:respone(Error_None)
end

---@param rpc_rsp RpcRsp
function GameRoleMgr:_handle_remote_call_change_gate_client(rpc_rsp, user_id, role_id)
    rpc_rsp:respone(Error_None)
end

---@param rpc_rsp RpcRsp
function GameRoleMgr:_handle_remote_call_release_role(rpc_rsp, user_id, role_id)
    rpc_rsp:respone(Error_None)
end

