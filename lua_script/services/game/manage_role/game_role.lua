
Game_Role_State = {
    free = 0,
    load_from_db = 1,
    in_game = 2,
    in_error = 3,
}

GameRole = GameRole or class("GameRole")

function GameRole:ctor(role_id)
    self.role_id = role_id
    self.user_id = nil
    self.state = Game_Role_State.free
    self.db_hash = math.random(1, 99999999)
    self.last_launch_sec = nil
    self.data_struct_version = nil
    self._modules = {}
    self.base_info = RoleBaseInfo:new(self)
    self._modules[self.base_info.module_name] = self.base_info
    self.last_save_sec = 0
    self._is_dirty = false
    self.world_client = nil
end

function GameRole.is_first_launch(db_ret)
    if nil == db_ret.last_launch_sec then
        return true
    end
    return false
end

function GameRole:set_dirty()
    self._is_dirty = true
end

function GameRole:clear_dirty()
    self._is_dirty = false
end

function GameRole:is_dirty()
    return self._is_dirty
end

function GameRole:module_set_dirty(module_name)
    self:set_dirty()
end

function GameRole:init_from_db(db_ret)
    self.last_save_sec = logic_sec()
    local data_struct_version = db_ret.data_struct_version or Data_Struct_Version_Game_Role
    if GameRole.is_first_launch(db_ret) then
        -- 第一次登陆，要做一些初始化操作
        self:set_dirty()
        self.last_save_sec = logic_sec() - Game_Role_Save_Span_Sec
    end

    local module_init_order = {
        self.base_info,
    }
    -- check module_init_order
    for _, v in pairs(self._modules) do
        local can_find = table.find(module_init_order, v)
        if not can_find then
            assert(false, string.format("module %s is not exist in module_init_order"))
        end
    end

    self.user_id = db_ret.user_id
    self.data_struct_version = data_struct_version
    self.last_launch_sec = db_ret.last_launch_sec or 0
    for _, v in ipairs(module_init_order) do
        v:init_from_db(db_ret)
    end
end

function GameRole:pack_for_db()
    ret = {}
    ret.role_id = self.role_id
    ret.user_id = self.user_id
    ret.data_struct_version = self.data_struct_version
    ret.last_launch_sec = self.last_launch_sec
    for _, role_module in pairs(self._modules) do
        role_module:pack_for_db(ret)
    end
    return ret
end

function GameRole:is_need_save()
    if Game_Role_State.in_game ~= self.state then
        return false
    end
    if not self:is_dirty() then
        return false
    end
    if logic_sec() - self.last_save_sec < Game_Role_Save_Span_Sec then
        return false
    end
    return true
end

function GameRole:save(db_client, db_name, coll_name)
    if Game_Role_State.in_game ~= self.state then
        return
    end
    self:clear_dirty()
    self.last_save_sec = logic_sec()
    local filter = {
        role_id = self.role_id,
    }
    local doc = self:pack_for_db()
    log_debug("GameRole:save: doc: %s", doc)
    db_client:find_one_and_replace(self.db_hash, db_name, coll_name, filter, doc, function(db_ret)
        log_debug("GameRole:save: db_ret:%s", db_ret)
    end)
end



