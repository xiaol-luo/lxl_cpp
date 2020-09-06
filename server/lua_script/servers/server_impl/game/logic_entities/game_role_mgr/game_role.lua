
---@class GameRole
---@field base_info RoleBaseInfo
---@field fight RoleFight
GameRole = GameRole or class("GameRole")

function GameRole:ctor(mgr, user_id, role_id)
    ---@type GameRoleMgr
    self._mgr = mgr
    self._user_id = user_id
    self._role_id = role_id
    self._state = Game_Role_State.free
    self._gate_server_key = nil
    self._gate_netid = nil
    self._world_server_key = nil

    self._db_hash = self._role_id
    self._db_ret = nil
    self._is_dirty = false
    self._is_module_dirty = {}
    self._role_modules = {}
    self._last_launch_sec = nil
    self._data_struct_version = nil
    self._last_save_sec = 0
end

function GameRole:init()
    self:_setup_module(RoleBaseInfo)
    self:_setup_module(RoleFight)

    for _, m in pairs(self._role_modules) do
        m:init()
    end
end

function GameRole:_setup_module(t_class)
    assert(t_class)
    local role_module = t_class:new(self)
    local module_name = role_module:get_module_name()
    assert(not self[module_name])
    assert(not self._role_modules[module_name])
    self._role_modules[module_name] = role_module
    self[module_name] = role_module
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

function GameRole:set_dirty()
    self._is_dirty = true
end

function GameRole:set_module_dirty(module_name)
    self._is_module_dirty[module_name] = true
end

function GameRole:clear_dirty()
    self._is_dirty = false
    self._is_module_dirty = {}
end

function GameRole:is_need_save()
    if Game_Role_State.in_game ~= self._state then
        return false
    end
    if not self:is_dirty() then
        return false
    end
    if logic_sec() - self._last_save_sec < Game_Role_Const.save_db_span_sec then
        return false
    end
    return true
end

function GameRole:check_and_save(db_client, db_name, coll_name, is_force)
    local need_save = is_force or self:is_need_save()
    if need_save then
        self:save_to_db(db_client, db_name, coll_name)
    end
end

function GameRole:save_to_db(db_client, db_name, coll_name)
    if Game_Role_State.in_game ~= self._state then
        return
    end

    local filter = {
        role_id = self._role_id,
    }
    local doc = {}
    local set_tb = {}
    doc["$set"] = set_tb

    local pack_info = self:pack_for_db(false)
    if self._is_dirty then
        set_tb.last_launch_sec = pack_info.last_launch_sec
        set_tb.data_struct_version = pack_info.data_struct_version
    end

    for module_name, role_module_info in pairs(pack_info.role_modules) do
        local set_key = string.format("role_modules.%s", module_name)
        set_tb[set_key] = role_module_info
    end

    self:clear_dirty()
    self._last_save_sec = logic_sec()
    if next(set_tb) then
        -- log_print("dbhash ", self.role_id, self._db_hash, doc)
        db_client:find_one_and_replace(self._role_id, db_name, coll_name, filter, doc, function(db_ret)
            -- log_debug("GameRole:save: role_id:%s db_ret:%s",self.role_id, db_ret)
        end)
    end
end

function GameRole:touch_launch_sec()
    self._last_launch_sec = os.time()
    self:set_dirty()
end

function GameRole.is_first_launch(db_ret)
    if nil == db_ret.last_launch_sec or nil == db_ret.data_struct_version then
        return true
    end
    return false
end

function GameRole:init_from_db(db_ret)
    if GameRole.is_first_launch(db_ret) then
        -- 第一次登陆，要做一些初始化操作
        self._last_save_sec = logic_sec() - Game_Role_Const.save_db_span_sec
        self:set_dirty()
        for _, m in pairs(self._role_modules) do
            m:set_dirty()
        end
    end

    self:touch_launch_sec()
    local init_ret = true
    self._data_struct_version = db_ret.data_struct_version or Game_Role_Data_Struct_Version.game_role
    for _, v in pairs(self._role_modules) do
        if not v:init_from_db(db_ret) then
            init_ret = false
            break
        end
    end
    return init_ret
end

function GameRole:pack_for_db(force_all)
    ret = {}
    ret.data_struct_version = self._data_struct_version
    ret.last_launch_sec = self._last_launch_sec
    ret.role_modules = {}
    for module_name, role_module in pairs(self._role_modules) do
        if self._is_module_dirty[module_name] or force_all then
            role_module:pack_for_db(ret.role_modules)
        end
    end
    return ret
end

function GameRole:get_user_id()
    return self._user_id
end

function GameRole:get_role_id()
    return self._role_id
end

function GameRole:set_state(val)
    self._state = val
end

function GameRole:get_state()
    return self._state
end

function GameRole:set_gate(gate_server_key, gate_netid)
    self._gate_server_key = gate_server_key
    self._gate_netid = gate_netid
end

function GameRole:get_gate()
    return self._gate_server_key, self._gate_netid
end

function GameRole:get_gate_netid()
    return self._gate_netid
end

function GameRole:get_gate_server_key()
    return self._gate_server_key
end

function GameRole:get_world_server_key()
    return self._world_server_key
end

function GameRole:set_world_server_key(val)
    -- log_print("GameRole:set_world_server_key", val)
    self._world_server_key = val
end

-- send msg to client，
-- 因为最经常发往客户端，所以send_msg这个简短的函数名默认指发给客户但
function GameRole:send_msg(pid, msg)
    if not self._gate_server_key or not self._gate_netid then
        return false
    end
    if not self._mgr then
        return false
    end
    if not is_number(pid) then
        return false
    end

    local is_ok, bytes = true, nil
    if msg then
        is_ok, bytes = self._mgr.server.pto_parser:encode(pid, msg)
    end
    if not is_ok then
        log_warn("GameRole:send_msg encode fail, pid %s and msg %s", is_ok, msg)
        return
    end
    self._mgr.server.rpc:call(nil, self._gate_server_key,
            Rpc.gate.method.forward_msg_to_client, self._gate_netid, pid, bytes)
    return true
end


