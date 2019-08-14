
RoomMgr = RoomMgr or class("RoomMgr", ServiceLogic)

function RoomMgr:ctor(logic_mgr, logic_name)
    RoomMgr.super.ctor(self, logic_mgr, logic_name)
    self._id_to_room = {}
end

function RoomMgr:init()
    RoomMgr.super.init(self)
    self:_init_process_rpc_handler()
end

function RoomMgr:start()
    RoomMgr.super.start(self)
end

function RoomMgr:stop()
    RoomMgr.super.stop(self)
end

function RoomMgr:on_update()

end
