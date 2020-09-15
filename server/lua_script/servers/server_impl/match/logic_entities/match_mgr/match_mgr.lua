
---@class MatchMgr:GameLogicEntity
MatchMgr = MatchMgr or class("MatchMgr", GameLogicEntity)

function MatchMgr:_on_init()
    MatchMgr.super._on_init(self)
    ---@type MatchServiceMgr
    self.server = self.server
end

function MatchMgr:_on_start()
    MatchMgr.super._on_start(self)
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.match.method.join_match, Functional.make_closure(self._handle_remote_call_join_match, self))
    -- self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.match.method.quit_match, Functional.make_closure(self._handle_remote_call_quit_match, self))
end

function MatchMgr:_on_stop()
    MatchMgr.super._on_stop(self)
    self._rpc_svc_proxy:clear_remote_call()
end

function MatchMgr:_on_release()
    MatchMgr.super._on_release(self)
end

function MatchMgr:_on_update()
    -- log_print("MatchMgr:_on_update")
end

---@param rpc_rsp RpcRsp
function MatchMgr:_handle_remote_call_join_match(rpc_rsp, role_id, token, fight_type)
    log_print("MatchMgr:_handle_remote_call_join_match", role_id, token, fight_type)
    rpc_rsp:response(Error_None)
end

---@param rpc_rsp RpcRsp
function MatchMgr:_handle_remote_call_quit_match(rpc_rsp, user_id)
    rpc_rsp:response()
end



