
RoomMgr = RoomMgr or class("RoomMgr", ServiceLogic)

function RoomMgr:ctor(logic_mgr, logic_name)
    RoomMgr.super.ctor(self, logic_mgr, logic_name)
    self._id_to_room = {}
end

function RoomMgr:init()
    RoomMgr.super.init(self)

    self.service.rpc_mgr:set_req_msg_process_fn(fn_name, Functional.make_closure(fn, self))
end

function RoomMgr:start()
    RoomMgr.super.start(self)
    self.timer_proxy:firm(Functional.make_closure(self._on_tick, self), 1 * 1000, -1)
end

function RoomMgr:stop()
    RoomMgr.super.stop(self)
end

function RoomMgr:_on_tick()

end

function RoomMgr:add_room(match_type, match_cell_list)
    local room = Room:new(gen_next_seq(), match_type, match_cell_list)
    self._id_to_room[room.room_id] = room

    -- todo:broadcast notify role to confirm
end

function RoomMgr:_on_rpc_cb_confirm_join_match()

end


