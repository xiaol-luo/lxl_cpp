
---@class RoomMgr:GameLogicEntity
RoomMgr = RoomMgr or class("RoomMgr", GameLogicEntity)

function RoomMgr:ctor(logics, logic_name)
    RoomMgr.super.ctor(self, logics, logic_name)
    ---@type RoomServiceMgr
    self.server = self.server
    ---@type RoomLogicService
    self.logics = self.logics
    ---@type table<string, RoomLogicBase>
    self._theme_to_logic = {}
end

function RoomMgr:_on_init()
    RoomMgr.super._on_init(self)

end

function RoomMgr:_on_start()
    RoomMgr.super._on_start(self)
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
    self._method_name_to_remote_call_handle_fns[Rpc.room.apply_room] = Functional.make_closure(self._on_rpc_apply_room, self)
end

---@param rpc_rsp RpcRsp
function RoomMgr:_on_rpc_apply_room(rpc_rsp, room_key, msg)
    log_print("MatchRoomMgr:_on_rpc_apply_room", room_key, msg)
    rpc_rsp:response(Error_None)
end


