
Room = Room or class("Room")

function Room:ctor()
    self.room_id = nil
    self.state = Room_State.free
    self.match_type = nil
    self.match_cells = {}
    self.fight_client = nil
    self.fight_battle_id = nil
    self.bind_roles = {}
    self.all_role_ids = {}
    self.fight_service_ip = nil
    self.fight_service_port = nil
    self.is_fight_started = false
    self.wait_role_ready_start_sec = nil
end

function Room:get_role(role_id)
    local ret = nil
    for _, cell in pairs(self.match_cells) do
        for _, cell_role in pairs(cell.roles) do
            if cell_role.role_id == role_id then
                ret = {
                    role_id = cell_role.role_id,
                    game_session_id = cell_role.game_session_id,
                }
            end
        end
    end
    if ret then
        local bind_role = self.bind_roles[role_id]
        if bind_role then
            ret.is_bind = true
            ret.game_service_key = bind_role.game_service_key
            ret.game_client = bind_role.game_client
        else
            ret.is_bind = false
        end
    end
    return ret
end

function Room:foreach_role(fn, ...)
    assert(IsFunction(fn))
    for role_id, _ in pairs(self.all_role_ids) do
        local role = self:get_role(role_id)
        if role then
            fn(role, ...)
        end
    end
end

function Room:is_all_bind()
    local is_all_bind = true
    for role_id, _ in pairs(self.all_role_ids) do
        if not self.bind_roles[role_id] then
            is_all_bind = false
            break
        end
    end
    return is_all_bind
end

