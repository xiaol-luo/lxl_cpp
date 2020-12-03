
---@class MatchMgr:GameLogicEntity
MatchMgr = MatchMgr or class("MatchMgr", GameLogicEntity)

function MatchMgr:_on_init()
    MatchMgr.super._on_init(self)
    ---@type MatchServiceMgr
    self.server = self.server
end

function MatchMgr:_on_start()
    MatchMgr.super._on_start(self)
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
    MatchMgr.super._on_update(self)
end

--- rpc函数


function MatchMgr:_on_map_remote_call_handle_fns()
    self._method_name_to_remote_call_handle_fns[Rpc.match.method.join_match] = Functional.make_closure(self._on_rpc_join_match, self)
    self._method_name_to_remote_call_handle_fns[Rpc.match.method.quit_match] = Functional.make_closure(self._on_rpc_quit_match, self)
end

---@param rpc_rsp RpcRsp
function MatchMgr:_on_rpc_join_match(rpc_rsp, msg)
    log_print("MatchMgr:_handle_remote_call_join_match", msg)
    rpc_rsp:response(Error_None)
end

---@param rpc_rsp RpcRsp
function MatchMgr:_on_rpc_quit_match(rpc_rsp, msg)
    log_print("MatchMgr:_on_rpc_quit_match", msg)
    rpc_rsp:response(Error_None)
end



