
---@class LogicMgrTemplate : EventMgr
LogicMgrTemplate = LogicMgrTemplate or class("LogicMgrTemplate", EventMgr)

function ExampleServiceMgrBase:ctor()
    ExampleServiceMgrBase.super.ctor(self)
    ---@type table<number, ExampleServiceBase>
    self._logics = {}
    ---@type Example_Service_Mgr_State
    self._curr_state = Example_Service_Mgr_State.Free
    self._error_num = nil
    self._error_msg = ""
end

---@param logic ExampleServiceBase
function ExampleServiceMgrBase:_add_logic(logic)
    local name = logic:get_name()
    self:_set_as_field(name, logic)
    table.insert(self._logics, logic)
end

function ExampleServiceMgrBase:_set_as_field(field_name, obj)
    if obj then
        assert(not self[field_name])
        self[field_name] = obj
    end
end

function ExampleServiceMgrBase:init()
    if Example_Service_Mgr_State.Free ~= self._curr_state then
        return false
    end
    self._curr_state = Example_Service_Mgr_State.Inited

    local ret = self:_on_init()
    return ret
end

function ExampleServiceMgrBase:start()
    if self._curr_state < Example_Service_Mgr_State.Starting then
        self._curr_state = Example_Service_Mgr_State.Starting
        for _, logic in pairs(self._logics) do
            logic:start()
        end
        self:_on_start()
        self:fire(Example_Service_Event.State_Starting, self)
    end
end

function ExampleServiceMgrBase:stop()
    if self._curr_state >= Example_Service_Mgr_State.Starting and self._curr_state < Example_Service_Mgr_State.Stopping then
        self._curr_state = Example_Service_Mgr_State.Stopping
        for _, logic in pairs(self._logics) do
            logic:stop()
        end
        self:_on_stop()
        self:fire(Example_Service_Event.State_Stopping, self)
    end
end

function ExampleServiceMgrBase:release()
    if Example_Service_Mgr_State.Released == self._curr_state then
        return
    end
    self._curr_state = Example_Service_Mgr_State.Released
    self:fire(Example_Service_Event.State_Released, self)
    for _, logic in pairs(self._logics) do
        logic:release()
    end
    self:cancel_all()
    self:_on_release()
end

function ExampleServiceMgrBase:get_error()
    return self._error_num, self._error_msg
end

function ExampleServiceMgrBase:get_curr_state()
    return self._curr_state
end

function ExampleServiceMgrBase:print_logic_state()
    for _, v in pairs(self._logics) do
        log_debug("logic state: %s is %s", v:get_name(), v:get_curr_state())
    end
end

function ExampleServiceMgrBase:update_logic()
    if not self._error_num then
        if Example_Service_Mgr_State.Update == self._curr_state then
            for _, m in pairs(self._logics) do
                m:update()
            end
            self:_on_update()
        end
        if Example_Service_Mgr_State.Started == self._curr_state then
            self._curr_state = Example_Service_Mgr_State.Update
            self:fire(Example_Service_Event.State_To_Update, self)
            for _, m in pairs(self._logics) do
                m:to_update_state()
            end
        end
        if Example_Service_Mgr_State.Starting == self._curr_state then
            local all_started = true
            for _, m in pairs(self._logics) do
                local e_num, e_msg = m:get_error()
                local m_curr_state = m:get_curr_state()
                if e_num then
                    all_started = false
                    self._error_num = e_num
                    self._error_msg = e_msg
                    log_error("ExampleServiceMgrBase Start Fail! logic=%s, error_num=%s, error_msg=%s", m:get_name(), self._error_num, self._error_msg)
                    break
                end
                if Example_Service_State.Started ~= m_curr_state then
                    all_started = false
                    break
                end
            end
            if all_started then
                self._curr_state = Example_Service_Mgr_State.Started
                self:_on_started()
                self:fire(Example_Service_Event.State_Started, self)
            end
        end
    end
    if Example_Service_Mgr_State.Stopping == self._curr_state then
        local all_stoped = true
        for _, m in pairs(self._logics) do
            local m_curr_state = m:get_curr_state()
            if Example_Service_State.Stopped ~= m_curr_state then
                all_stoped = false
                break
            end
        end
        if all_stoped then
            self._curr_state = Example_Service_Mgr_State.Stopped
            self:fire(Example_Service_Event.State_Stopped, self)
        end
    end
end

function ExampleServiceMgrBase:_on_init(arg)
    -- override by subclass
end

function ExampleServiceMgrBase:_on_start()
    -- override by subclass
end

function ExampleServiceMgrBase:_on_started()
    -- override by subclass
end

function ExampleServiceMgrBase:_on_stop()
    -- override by subclass
end

function ExampleServiceMgrBase:_on_stoped()
    -- override by subclass
end

function ExampleServiceMgrBase:_on_release()
    -- override by subclass
end

function ExampleServiceMgrBase:_on_update()
    -- override by subclass
end




