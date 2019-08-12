
Room = Room or class("Room")

function Room:ctor(room_id, match_type, match_cell_list)
    self.room_id = room_id
    self.match_type = match_type
    self.match_cell_list = match_cell_list
end


