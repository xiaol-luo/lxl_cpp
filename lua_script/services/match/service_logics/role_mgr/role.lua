
Role = Role or class("Role")

function Role:ctor(role_id)
    self.role_id = role_id
    self.match_logic = nil
    self.match_cell_id = nil
end

function Role:set_match_cell(match_logic, match_cell_id)
    self.match_logic = match_logic
    self.match_cell_id = match_cell_id
end

function Role:clear_match_cell()
    self.match_logic = nil
    self.match_cell_id = nil
end



