
Role = Role or class("Role")

function Role:ctor(role_id)
    self.role_id = role_id
    self.base_info = nil
    self.match_cell_id = nil
end



