
Room = Room or class("Room")

function Room:ctor()
    self.room_id = nil
    self.state = Room_State.free
    self.match_type = nil
    self.match_cells = {}
    self.fight_client = nil
    self.fight_battle_id = nil
    self.ready_role_ids = {}
end

