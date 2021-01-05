
---@class FightLogic:LogicBase
FightLogic = FightLogic or class("FightLogic", LogicBase)

function FightLogic:ctor(logic_mgr)
    FightLogic.super.ctor(self, logic_mgr, "fight")
    ---@type RoomData
    self._room_data = nil
end

function FightLogic:_on_init()
    self._room_data = self._app.data_mgr.room
    self._event_binder:bind(self._room_data, Room_Data_Event.ask_enter_room,
            Functional.make_closure(self._on_event_ask_enter_room, self))
end

function FightLogic:_on_event_ask_enter_room(ev_data)
    local room_key = ev_data.room_key
    local match_server_key = ev_data.match_server_key

end




