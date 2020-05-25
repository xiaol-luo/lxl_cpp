
RoleMgr = RoleMgr or class("RoleMgr")

function RoleMgr:ctor(main_logic)
    self.main_logic = main_logic
    self.event_subscriber = self.main_logic.event_mgr:create_subscriber()
    self._roles = {}
end

function RoleMgr:init()
end

function RoleMgr:add_role(role)
    self._roles[role.role_id] = role
end

function RoleMgr:remove_role(role_id)
    self._roles[role_id] = nil
end

function RoleMgr:get_role(role_id)
    return self._roles[role_id]
end






