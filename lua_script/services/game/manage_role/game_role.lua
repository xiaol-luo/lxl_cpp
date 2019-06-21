
Game_Role_State = {
    free = 0,
    load_from_db = 1,
    in_game = 2,
    in_error = 3,
}

GameRole = GameRole or class("GameRole")

function GameRole:ctor(role_id)
    self.role_id = role_id
    self.state = Game_Role_State.free
    self.db_hash = math.random(1, 99999999)
    self.last_launch_sec = nil
end

function GameRole:init_from_db(db_ret)
    local is_first_launch = nil == db_ret.last_launch_sec
    self.last_launch_sec = db_ret.last_launch_sec or 0
    if is_first_launch then

    end
end

