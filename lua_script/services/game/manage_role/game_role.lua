
Game_Role_State = {
    free = 0,
    load_from_db = 1,
    in_game = 2,
    in_error = 3,
}

GameRole = GameRole or class("GameRole")

function GameRole:ctor(role_id)
    self.role_id = role_id
    self.state = Game_Role_State.free
    self.db_hash = math.random(1, 99999999)
    self.last_launch_sec = nil
    self.data_struct_version = nil
    self.modules = {}
    self.modules[RoleBaseInfo.Module_Name] = RoleBaseInfo:new(self)
end

function GameRole.is_first_launch(db_ret)
    if nil == db_ret.last_launch_sec then
        return true
    end
    return false
end

function GameRole:init_from_db(db_ret)
    local data_struct_version = db_ret.data_struct_version or Data_Struct_Version_Game_Role
    if GameRole.is_first_launch(db_ret) then
        -- 第一次登陆，要做一些初始化操作
    end

    local module_init_order = {
        RoleBaseInfo.Module_Name,
    }
    -- check module_init_order
    for module_name, _ in pairs(self.modules) do
        local can_find = table.find(module_init_order, module_name)
        if not can_find then
            assert(false, string.format("module %s is not exist in module_init_order"))
        end
    end

    self.data_struct_version = data_struct_version
    self.last_launch_sec = db_ret.last_launch_sec or 0
    for _, module_name in ipairs(module_init_order) do
        self.modules[module_name]:init_from_db(db_ret)
    end
end

function GameRole:pack_for_db()
    ret = {}
    ret.role_id = self.role_id
    ret.data_struct_version = self.data_struct_version
    ret.last_launch_sec = self.last_launch_sec
    for _, role_module in pairs(self.modules) do
        role_module:pack_for_db(ret)
    end
    return ret
end

function GetBaseInfo()
    return self.modules[RoleBaseInfo.Module_Name]
end

function GetRoleId()
    return self.role_id
end


