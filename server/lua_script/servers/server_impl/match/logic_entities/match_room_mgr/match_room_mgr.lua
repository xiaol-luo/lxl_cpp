
---@class MatchRoomMgr:GameLogicEntity
MatchRoomMgr = MatchRoomMgr or class("MatchRoomMgr", GameLogicEntity)

function MatchRoomMgr:_on_init()
    MatchRoomMgr.super._on_init(self)
    ---@type MatchServiceMgr
    self.server = self.server
end

function MatchRoomMgr:_on_start()
    MatchRoomMgr.super._on_start(self)
end

function MatchRoomMgr:_on_stop()
    MatchRoomMgr.super._on_stop(self)
    self._rpc_svc_proxy:clear_remote_call()
end

function MatchRoomMgr:_on_release()
    MatchRoomMgr.super._on_release(self)
end

function MatchRoomMgr:_on_update()
    -- log_print("MatchRoomMgr:_on_update")
    MatchRoomMgr.super._on_update(self)
end

--- rpc函数


function MatchRoomMgr:_on_map_remote_call_handle_fns()
    -- self._method_name_to_remote_call_handle_fns[Rpc.match.method.join_match] = Functional.make_closure(self._on_rpc_join_match, self)
end

---@param rpc_rsp RpcRsp
function MatchRoomMgr:_on_rpc_join_match(rpc_rsp, msg)
    log_print("MatchRoomMgr:_handle_remote_call_join_match", msg)
    rpc_rsp:response(Error_None)
end




