

RoleRoom = RoleRoom or class("RoleRoom", RoleModuleBase)
RoleRoom.Module_Name = "match"

function RoleRoom:ctor(role)
    RoleRoom.super.ctor(self, role, RoleRoom.Module_Name)
    self.join_match_type = Match_Type.none
    self.state = Role_Match_State.free
    self.match_client = nil
    self.match_session_id = nil
    self.match_cell_id = nil
end

function RoleRoom:init()
    RoleRoom.super.init(self)
    self:init_process_client_msg()
end

function RoleRoom:init_from_db(db_ret)

end

function RoleRoom:pack_for_db(out_ret)
    local db_info = {}
    return self.module_name, db_info
end

