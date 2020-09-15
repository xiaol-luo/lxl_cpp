
---@class MatchRoleMgr:GameLogicEntity
MatchRoleMgr = MatchRoleMgr or class("MatchRoleMgr", GameLogicEntity)

function MatchRoleMgr:_on_init()
    MatchRoleMgr.super._on_init(self)
    ---@type MatchServiceMgr
    self.server = self.server
end

function MatchRoleMgr:_on_start()
    MatchRoleMgr.super._on_start(self)
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.match.method.quit_match, Functional.make_closure(self._handle_remote_call_quit_match, self))
end

function MatchRoleMgr:_on_stop()
    MatchRoleMgr.super._on_stop(self)
    self._rpc_svc_proxy:clear_remote_call()
end

function MatchRoleMgr:_on_release()
    MatchRoleMgr.super._on_release(self)
end

function MatchRoleMgr:_on_update()
    -- log_print("MatchRoleMgr:_on_update")
end

---@param rpc_rsp RpcRsp
function MatchRoleMgr:_handle_remote_call_quit_match(rpc_rsp, user_id)
    rpc_rsp:response()
end



