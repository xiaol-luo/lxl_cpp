
RoleMgr = RoleMgr or class("RoleMgr")

function RoleMgr:ctor()
    self._roles = {}
end

function RoleMgr:add_role(role)
    self._roles[role.role_id] = role
end

function RoleMgr:remove_role(role_id)
    self._roles[role_id] = nil
end

function RoleMgr:tick_role()
    for _, v in pairs(self._roles) do
        v:say_hi()
        v:tell_a()
    end
    -- print("RoleMgr:tick_role")
end

print("reach role mgr")


