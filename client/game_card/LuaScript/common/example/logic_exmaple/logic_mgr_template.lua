
---@class LogicMgrTemplate : EventMgr
LogicMgrTemplate = LogicMgrTemplate or class("LogicMgrTemplate", EventMgr)

function LogicMgrTemplate:ctor()
    LogicMgrTemplate.super.ctor(self)
    ---@type table<number, LogicBaseTemplate>
    self._logics = {}
    ---@type Logic_Mgr_Template_State
    self.curr_state = Logic_Mgr_Template_State.Free
    self.error_num = nil
    self.error_msg = ""
end

---@param logic LogicBaseTemplate
function LogicMgrTemplate:_add_logic(logic)
    local name = logic:get_name()
    self:_set_as_field(name, logic)
    table.insert(self._logics, logic)
end

function LogicMgrTemplate:_set_as_field(field_name, obj)
    if obj then
        assert(not self[field_name])
        self[field_name] = obj
    end
end

function LogicMgrTemplate:init()
    if Logic_Mgr_Template_State.Free ~= self.curr_state then
        return false
    end
    self.curr_state = Logic_Mgr_Template_State.Inited

    local ret = self:_on_init()
    return ret
end

function LogicMgrTemplate:start()
    if self.curr_state < Logic_Mgr_Template_State.Starting then
        self.curr_state = Logic_Mgr_Template_State.Starting
        self:fire(Logic_Template_Event.State_Starting, self)
        for _, logic in pairs(self._logics) do
            logic:start()
        end
    end
end

function LogicMgrTemplate:stop()
    if self.curr_state >= Logic_Mgr_Template_State.Starting and self.curr_state < Logic_Mgr_Template_State.Stopping then
        self.curr_state = Logic_Mgr_Template_State.Stopping
        self:fire(Logic_Template_Event.State_Stopping, self)
        for _, logic in pairs(self._logics) do
            logic:stop()
        end
    end
end

function LogicMgrTemplate:release()
    if Logic_Mgr_Template_State.Released == self.curr_state then
        return
    end
    self.curr_state = Logic_Mgr_Template_State.Released
    for _, logic in pairs(self._logics) do
        logic:release()
    end
    self:fire(Logic_Template_Event.State_Released, self)
    self:cancel_all()
end

function LogicMgrTemplate:get_error()
    return self.error_num, self.error_msg
end

function LogicMgrTemplate:get_curr_state()
    return self.curr_state
end

function LogicMgrTemplate:print_logic_state()
    for _, v in pairs(self._logics) do
        log_debug("service state: %s is %s", v:get_name(), v:get_curr_state())
    end
end

function LogicMgrTemplate:update_logic()
    if not self.error_num then
        if Logic_Mgr_Template_State.Update == self.curr_state then
            for _, m in pairs(self._logics) do
                m:update()
            end
        end
        if Logic_Mgr_Template_State.Started == self.curr_state then
            self.curr_state = Logic_Mgr_Template_State.Update
            self:fire(Logic_Template_Event.State_To_Update, self)
            for _, m in pairs(self._logics) do
                m:to_update_state()
            end
        end
        if Logic_Mgr_Template_State.Starting == self.curr_state then
            local all_started = true
            for _, m in pairs(self._logics) do
                local e_num, e_msg = m:get_error()
                local m_curr_state = m:get_curr_state()
                if e_num then
                    all_started = false
                    self.error_num = e_num
                    self.error_msg = e_msg
                    log_error("LogicMgrTemplate Start Fail! service=%s, error_num=%s, error_msg=%s", m:get_service_name(), self.error_num, self.error_msg)
                    break
                end
                if Logic_Template_State.Started ~= m_curr_state then
                    all_started = false
                    break
                end
            end
            if all_started then
                self.curr_state = Logic_Mgr_Template_State.Started
                self:fire(Logic_Template_Event.State_Started, self)
            end
        end
    end
    if Logic_Mgr_Template_State.Stopping == self.curr_state then
        local all_stoped = true
        for _, m in pairs(self._logics) do
            local m_curr_state = m:get_curr_state()
            if Logic_Template_State.Stopped ~= m_curr_state then
                all_stoped = false
                break
            end
        end
        if all_stoped then
            self.curr_state = Logic_Mgr_Template_State.Stopped
            self:fire(Logic_Template_Event.State_Stopped, self)
        end
    end
end


function LogicMgrTemplate:_on_init()
    assert(false,"should not reach here")
end




