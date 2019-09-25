
MatchCell = MatchCell or class("MatchCell")

function MatchCell:ctor(match_logic, id)
    self.match_logic = match_logic
    self.cell_id = id
    self.leader_role_id = nil
    self.role_ids = {}
    self.extra_data = nil
    self.room_id = nil
end

function MatchCell:set_leader_role_id(role_id)
    if not role_id or not self.role_ids[role_id] then
        return false
    end
    self.leader_role_id = role_id
    return true
end

function MatchCell:add_role(role_id)
    self.role_ids[role_id] = true
    if not self.leader_role_id then
        self:set_leader_role_id(role_id)
    end
end

function MatchCell:remove_role(role_id)
    self.role_ids[role_id] = nil
    if self.leader_role_id and self.leader_role_id == role_id then
        local new_leader_role_id = next(self.leader_role_id)
        self:set_leader_role_id(new_leader_role_id)
    end
end

function MatchCell:role_count()
    return table.size(self.role_ids) -- todo:优化效率
end






