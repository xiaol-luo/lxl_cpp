
MatchLogicBalance = MatchLogicBalance or class("MatchLogicBalance", MatchLogic)

function MatchLogicBalance:ctor(match_mgr, match_type)
    MatchLogicBalance.super.ctor(self, match_mgr, match_type)
    self.id_to_cell = {}
    self.room_role_count = 2
    assert(2 == self.room_role_count)
    self._last_do_match_sec = 0
    self._do_match_span_sec = 2
end

function MatchLogicBalance:_create_match_cell()
    local cell = MatchCellBalance:new(self, gen_next_seq())
    self.id_to_cell[cell.cell_id] = cell
end

function MatchLogicBalance:solo_join(role_id)
    return self:join(role_id, { role_id })
end

function MatchLogicBalance:join(leader_role_id, role_ids, extra_data)
    if not leader_role_id then
        return Error.Join_Match.match_leader_role_id_nil
    end
    local role_mgr = self.service.role_mgr
    local leader_role = role_mgr:add_role(leader_role_id)
    if leader_role.match_cell_id then
        return Error.Join_Match.match_role_already_in_match, leader_role
    end
    local role_id_map = {[leader_role_id ] = true}
    for _, role_id in pairs(role_ids) do
        role_id_map[role_id] = true
    end
    if table.size(role_id_map) > self.room_role_count then
        return Error.Join_Match.join_match_role_count_illegal
    end
    local role_map = { [leader_role.role_id] = leader_role }
    for _, role_id in pairs(role_ids) do
        if not role_map[role_id] then
            local role = role_mgr:add_role(role_id)
            if role.match_cell_id then
                return Error.Join_Match.match_role_already_in_match, role
            end
            role_map[role.role_id] = role
        end
    end
    local match_cell = self:_create_match_cell()
    for role_id, role in pairs(role_map) do
        match_cell:add_role(role_id)
        role:set_match_cell(self, match_cell.cell_id)
    end
    match_cell:set_leader_role_id(leader_role_id)
    match_cell.extra_data = extra_data
    return Error_None, match_cell
end

function MatchLogicBalance:quit(role_id, match_cell_id)
    local match_cell = self.id_to_cell[match_cell_id]
    if not match_cell then
        return Error.Quit_Match.match_cell_not_exist, match_cell_id
    end
    if not role_id or role_id ~= match_cell.leader_role_id then
        return Error.Quit_Match.role_has_no_right_to_quit
    end
    self.id_to_cell[match_cell_id] = nil
    for role_id, _ in pairs(match_cell.role_ids) do
        local role = self.service.role_mgr:get_role(role_id)
        if role and role.match_logic == self and role.match_cell_id == match_cell_id then
            role:clear_match_cell()
            self.service.role_mgr:remove_role(role_id)
        end
    end
    return Error_None, match_cell
end

function MatchLogicBalance:update_logic()
    local now_sec = logic_sec()
    if now_sec - self._last_do_match_sec >= self._do_match_span_sec then
        self._last_do_match_sec = now_sec
        local ready_room_map = {}
        local fn_make_room = function(...)
            local room_id = gen_next_seq()
            ready_room_map[room_id] = {
                room_id = room_id,
                cells = {...}
            }
        end
        local to_remove_cell = {}
        local one_role_cell = nil
        for _, cell in pairs(self.id_to_cell) do
            local role_count = cell:role_count()
            if role_count <= 0 then
                table.insert(to_remove_cell, cell)
            elseif role_count >= self.room_role_count then
                fn_make_room(cell)
                table.insert(to_remove_cell, cell)
            else
                if not one_role_cell then
                    one_role_cell = cell
                else
                    fn_make_room(one_role_cell, cell)
                    table.insert(to_remove_cell, one_role_cell)
                    table.insert(to_remove_cell, cell)
                    one_role_cell = nil
                end
            end
        end
        for _, cell in pairs(to_remove_cell) do
            self.id_to_cell[cell.cell_id] = nil
            -- todo:
        end
        for room_id, room in pairs(ready_room_map) do
            -- todo:
        end
    end
end

