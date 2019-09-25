
RoleModuleBase = RoleModuleBase or class("RoleModuleBase")

function RoleModuleBase:ctor(role, module_name)
    self.role = role
    self.module_name = module_name
end

function RoleModuleBase:init()

end

function RoleModuleBase:init_from_db(db_ret)

end

function RoleModuleBase:pack_for_db(out_ret)
    --[[ example
    info = {}
    -- ...
    if out_ret then
        out_ret.xxx = info
    end
    return info
    --]]
end

function RoleModuleBase:set_dirty()
    self.role:module_set_dirty(self.module_name)
end