
RoomMgr = RoomMgr or class("RoomMgr", ServiceLogic)

function RoomMgr:ctor(logic_mgr, logic_name)
    RoomMgr.super.ctor(self, logic_mgr, logic_name)
end

function RoomMgr:init()
    RoomMgr.super.init(self)
end

function RoomMgr:start()
    RoomMgr.super.start(self)
end

function RoomMgr:stop()
    RoomMgr.super.stop(self)
end
