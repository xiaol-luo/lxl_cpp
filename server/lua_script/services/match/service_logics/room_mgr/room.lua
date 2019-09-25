
Room = Room or class("Room")

Room.Confirm_Join_Timeout_Sec = 15

function Room:ctor(room_id, match_type, match_cell_list)
    self.room_id = room_id
    self.match_type = match_type
    self.match_cell_list = match_cell_list
    self.confirm_join_start_sec = nil
    self.confirm_join_results = {}
    self._is_confirm_join_finished = false
    self.room_client = nil
    self.remote_room_id = nil
end

function Room:set_confirm_join_result(role_id, is_accept)
    if self:is_confirm_join_finished() then
        return
    end
    if self.confirm_join_results[role_id] then
        -- return
    end
    self.confirm_join_results[role_id] = is_accept
    self:check_confirm_join_result()
end

function Room:check_confirm_join_result()
    if nil == self.confirm_join_start_sec then
        return
    end
    if self._is_confirm_join_finished then
        return
    end
    local now_sec = logic_sec()
    if now_sec - self.confirm_join_start_sec >= Room.Confirm_Join_Timeout_Sec then
        self._is_confirm_join_finished = true
    else
        local all_accept = true
        for role_id, _ in pairs(self:get_role_ids()) do
            if not self.confirm_join_results[role_id] then
                all_accept = false
                break
            end
        end
        if all_accept then
            self._is_confirm_join_finished = true
        end
    end
end

function Room:is_confirm_join_finished()
    self:check_confirm_join_result()
    return self._is_confirm_join_finished
end

function Room:get_reject_confirm_join_role_ids()
    local ret = {}
    for role_id, _ in pairs(self:get_role_ids()) do
        if not self.confirm_join_results[role_id] then
            ret[role_id] = true
        end
    end
    return ret
end

function Room:get_reject_confirm_join_cells()
    local ret = {}
    for role_id, _ in pairs(self:get_reject_confirm_join_role_ids()) do
        local role = SERVICE_MAIN.role_mgr:get_role(role_id)
        if role and role.match_room_id then
            if not ret[role.match_room_id] then
                local room = SERVICE_MAIN.match_mgr:get_cell(role.match_type, role.match_cell_id)
                ret[room.room_id] = room
            end
        end
    end
    return ret
end

function Room:get_role_ids()
    local ret = {}
    for _, cell in ipairs(self.match_cell_list) do
        for role_id, _ in pairs(cell.role_ids) do
            ret[role_id] = true
        end
    end
    return ret
end

function Room:foreach_role(fn, ...)
    if not IsFunction(fn) then
        return
    end
    for role_id, _ in pairs(self:get_role_ids()) do
        fn(role_id, ...)
    end
end


