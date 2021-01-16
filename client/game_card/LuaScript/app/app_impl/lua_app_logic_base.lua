
---@class LuaAppLogicBase: EventMgr
---@field logic_mgr ServiceMgrBase
---@field server GameServerBase
LuaAppLogicBase = LuaAppLogicBase or class("LuaAppLogicBase", EventMgr)

function LuaAppLogicBase:ctor(logic_mgr, logic_name)
    LuaAppLogicBase.super.ctor(self)
    self.logic_mgr = logic_mgr
    self._logic_name = logic_name
    ---@type Logic_Mgr_Template_State
    self._curr_state = Lua_App_Logic_State.Free
    self._event_binder = EventBinder:new()
    self._timer_proxy = TimerProxy:new()
    self._error_num = nil
    self._error_msg = ""
end

function LuaAppLogicBase:get_name()
    return self._logic_name
end

function LuaAppLogicBase:get_error()
    return self._error_num, self._error_msg
end

function LuaAppLogicBase:get_curr_state()
    return self._curr_state
end

function LuaAppLogicBase:to_update_state()
    if Lua_App_Logic_State.Started == self._curr_state then
        self._curr_state = Lua_App_Logic_State.Update
    end
end

function LuaAppLogicBase:init(...)
    self._curr_state = Lua_App_Logic_State.Inited
    self:_on_init(...)
end

function LuaAppLogicBase:start()
    self._curr_state = Lua_App_Logic_State.Started
    self:_on_start()
end

function LuaAppLogicBase:stop()
    self._curr_state = Lua_App_Logic_State.Stopped
    self:_on_stop()
end

function LuaAppLogicBase:release()
    self._curr_state = Lua_App_Logic_State.Released
    self._event_binder:release_all()
    self._timer_proxy:release_all()
    self:_on_release()
end

function LuaAppLogicBase:update()
    if Lua_App_Logic_State.Update == self._curr_state then
        self:_on_update()
    end
end

function LuaAppLogicBase:_on_init(...)
    -- override by subclass
end

function LuaAppLogicBase:_on_start()
    -- override by subclass
end

function LuaAppLogicBase:_on_stop()
    -- override by subclass
end

function LuaAppLogicBase:_on_release()
    -- override by subclass
end

function LuaAppLogicBase:_on_update()
    -- override by subclass
end











