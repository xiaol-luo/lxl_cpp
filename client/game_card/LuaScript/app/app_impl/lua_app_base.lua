
---@class LuaAppBase : EventMgr
LuaAppBase = LuaAppBase or class("LuaAppBase", EventMgr)

function LuaAppBase:ctor()
    LuaAppBase.super.ctor(self)
    ---@type table<number, LogicBaseTemplate>
    self._logics = {}
    ---@type Lua_App_State
    self._curr_state = Lua_App_State.Free
    self._error_num = nil
    self._error_msg = ""
end

---@param logic LogicBaseTemplate
function LuaAppBase:_add_logic(logic)
    local name = logic:get_name()
    self:_set_as_field(name, logic)
    table.insert(self._logics, logic)
end

function LuaAppBase:_set_as_field(field_name, obj)
    if obj then
        assert(not self[field_name])
        self[field_name] = obj
    end
end

function LuaAppBase:init(arg)
    if Lua_App_State.Free ~= self._curr_state then
        return false
    end
    self._curr_state = Lua_App_State.Inited

    local ret = self:_on_init(arg)
    return ret
end

function LuaAppBase:start()
    if self._curr_state < Lua_App_State.Starting then
        self._curr_state = Lua_App_State.Starting
        self:fire(Lua_App_Event.State_Starting, self)
        for _, logic in pairs(self._logics) do
            logic:start()
        end
        self:_on_start()
    end
end

function LuaAppBase:stop()
    if self._curr_state >= Lua_App_State.Starting and self._curr_state < Lua_App_State.Stopping then
        self._curr_state = Lua_App_State.Stopping
        self:fire(Lua_App_Event.State_Stopping, self)
        for _, logic in pairs(self._logics) do
            logic:stop()
        end
        self:_on_stop()
    end
end

function LuaAppBase:release()
    if Lua_App_State.Released == self._curr_state then
        return
    end
    self._curr_state = Lua_App_State.Released
    for _, logic in pairs(self._logics) do
        logic:release()
    end
    self:fire(Lua_App_Event.State_Released, self)
    self:cancel_all()
    self:_on_release()
end

function LuaAppBase:get_error()
    return self._error_num, self._error_msg
end

function LuaAppBase:get_curr_state()
    return self._curr_state
end

function LuaAppBase:print_logic_state()
    for _, v in pairs(self._logics) do
        log_debug("logic state: %s is %s", v:get_name(), v:get_curr_state())
    end
end

function LuaAppBase:update()
    if not self._error_num then
        if Lua_App_State.Update == self._curr_state then
            for _, m in pairs(self._logics) do
                m:update()
            end
            self:_on_update()
        end
        if Lua_App_State.Started == self._curr_state then
            self._curr_state = Lua_App_State.Update
            self:fire(Lua_App_Event.State_To_Update, self)
            for _, m in pairs(self._logics) do
                m:to_update_state()
            end
        end
        if Lua_App_State.Starting == self._curr_state then
            local all_started = true
            for _, m in pairs(self._logics) do
                local e_num, e_msg = m:get_error()
                local m_curr_state = m:get_curr_state()
                if e_num then
                    all_started = false
                    self._error_num = e_num
                    self._error_msg = e_msg
                    log_error("LuaAppBase Start Fail! logic=%s, error_num=%s, error_msg=%s", m:get_name(), self._error_num, self._error_msg)
                    break
                end
                if Lua_App_Logic_State.Started ~= m_curr_state then
                    all_started = false
                    break
                end
            end
            if all_started then
                self._curr_state = Lua_App_State.Started
                self:fire(Lua_App_Event.State_Started, self)
                self:_on_started()
            end
        end
    end
    if Lua_App_State.Stopping == self._curr_state then
        local all_stoped = true
        for _, m in pairs(self._logics) do
            local m_curr_state = m:get_curr_state()
            if Lua_App_Logic_State.Stopped ~= m_curr_state then
                all_stoped = false
                break
            end
        end
        if all_stoped then
            self._curr_state = Lua_App_State.Stopped
            self:fire(Lua_App_Event.State_Stopped, self)
            self:_on_stoped()
        end
    end
end


function LuaAppBase:_on_init(arg)
    -- override by subclass
end

function LuaAppBase:_on_start()
    -- override by subclass
end

function LuaAppBase:_on_started()
    -- override by subclass
end

function LuaAppBase:_on_stop()
    -- override by subclass
end

function LuaAppBase:_on_stoped()
    -- override by subclass
end

function LuaAppBase:_on_release()
    -- override by subclass
end

function LuaAppBase:_on_update()
    -- override by subclass
end



