
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
    self.last_save_sec = 0
    self._is_dirty = false
    self._is_module_dirty = {}
    self.world_client = nil
    self.gate_client = nil
    self.gate_client_netid = nil
    self._process_client_msg_fns = {}

    self._modules = {}
    self:_setup_module(RoleBaseInfo, RoleBaseInfo.Module_Name)
    self:_setup_module(RoleMatch, RoleMatch.Module_Name)
end

function GameRole:init()
    for _, m in pairs(self._modules) do
        m:init()
    end
end

function GameRole:_setup_module(t_class, module_name)
    assert(t_class)
    assert(module_name)
    assert(not self[module_name])
    assert(not self._modules[module_name])
    self._modules[module_name] = t_class:new(self)
    self[module_name] = self._modules[module_name]
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
    self._is_module_dirty = {}
end

function GameRole:is_dirty()
    if self._is_dirty then
        return true
    end
    if next(self._is_module_dirty) then
        return true
    end
    return false
end

function GameRole:module_set_dirty(module_name)
    self._is_module_dirty[module_name] = true
end

function GameRole:set_launch_sec()
    self.last_launch_sec = logic_sec()
    self:set_dirty()
end

function GameRole:init_from_db(db_ret)
    self.last_save_sec = logic_sec()
    local data_struct_version = db_ret.data_struct_version or Data_Struct_Version_Game_Role
    if GameRole.is_first_launch(db_ret) then
        -- 第一次登陆，要做一些初始化操作
        self:set_dirty()
        self.last_save_sec = logic_sec() - Game_Role_Save_Span_Sec
        for _, m in pairs(self._modules) do
            m:set_dirty()
        end
    end

    local module_init_order = {
        self.base_info,
        self.match,
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
    self:set_launch_sec()
    for _, v in ipairs(module_init_order) do
        v:init_from_db(db_ret.modules or {})
    end
end

function GameRole:pack_for_db()
    ret = {}
    ret.data_struct_version = self.data_struct_version
    ret.last_launch_sec = self.last_launch_sec
    ret.modules = {}
    for _, role_module in pairs(self._modules) do
        role_module:pack_for_db(ret.modules)
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
    local filter = {
        role_id = self.role_id,
    }

    local doc = {}
    local set_tb = {}
    doc["$set"] = set_tb

    local pack_info = self:pack_for_db()
    if self._is_dirty then
        set_tb.last_launch_sec = pack_info.last_launch_sec
        set_tb.data_struct_version = pack_info.data_struct_version
    end

    for module_name, _ in pairs(self._is_module_dirty) do
        if self._modules[module_name] and pack_info.modules[module_name] then
            local set_key_format = "modules.%s"
            local set_key = string.format(set_key_format, module_name)
            set_tb[set_key] = pack_info.modules[module_name]
        end
    end

    self:clear_dirty()
    self.last_save_sec = logic_sec()

    -- log_debug("GameRole:save: doc: %s", doc)
    db_client:find_one_and_replace(self.db_hash, db_name, coll_name, filter, doc, function(db_ret)
        -- log_debug("GameRole:save: db_ret:%s", db_ret)
    end)
end

function GameRole:set_client_msg_process_fn(pid, fn)
    assert(IsNumber(pid))
    assert(nil == fn or IsFunction(fn))
    if not fn then
        assert(not self._process_client_msg_fns[pid])
    end
    self._process_client_msg_fns[pid] = fn
end

function GameRole:has_client_msg_process_fn(pid)
    return nil ~= self._process_client_msg_fns[pid]
end

function GameRole:on_client_msg(pid, msg)
    local fn = self._process_client_msg_fns[pid]
    if not fn then
        log_warn("GameRole:on_client_msg can not find process fn to process pid %s", pid)
        return
    end
    fn(pid, msg)
end

function GameRole:send_to_client(pid, msg)
    return SERVICE_MAIN.net_forward:to_client(self.role_id, pid, msg)
end




