
---@class RoomMgr:GameLogicEntity
RoomMgr = RoomMgr or class("RoomMgr", GameLogicEntity)

function RoomMgr:_on_init()
    RoomMgr.super._on_init(self)
    ---@type MatchServiceMgr
    self.server = self.server
end

function RoomMgr:_on_start()
    RoomMgr.super._on_start(self)
    -- self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.create_role.query_roles, Functional.make_closure(self._handle_remote_call_query_roles, self))
    -- self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.create_role.create_role, Functional.make_closure(self._handle_remote_call_create_role, self))
end

function RoomMgr:_on_stop()
    RoomMgr.super._on_stop(self)
    self._rpc_svc_proxy:clear_remote_call()
end

function RoomMgr:_on_release()
    RoomMgr.super._on_release(self)
end

function RoomMgr:_on_update()
    -- log_print("RoomMgr:_on_update")
end

--- rpc函数

function RoomMgr:_on_map_remote_call_handle_fns()
    -- self._method_name_to_remote_call_handle_fns[Rpc.match.join_match] = Functional.make_closure(self._on_rpc_join_match, self)
end

---@param rpc_rsp RpcRsp
function RoomMgr:_on_rpc_join_match(rpc_rsp, msg)
    log_print("MatchRoomMgr:_handle_remote_call_join_match", msg)
    rpc_rsp:response(Error_None)
end


