
StateMgr = StateMgr or class("StateMgr")

function StateMgr:ctor()
    self.last_state = nil
    self.active_state = nil
    self.state_map = {}
end

function StateMgr:init()
    self:_prepare_all_states()
    for _, v in pairs(self.state_map) do
        v:init()
    end
end

function StateMgr:_prepare_all_states()

end

function StateMgr:_add_state_help(st)
    local st_name = st:get_name()
    log_assert(not self.state_map[st_name], "dumplicate state %s", st_name)
    self.state_map[st_name] = st
end

function StateMgr:update_state()
    if self.active_state then
        self.active_state:update()
    end
end

function StateMgr:change_state(state_name, params)
    local next_state = self.state_map[state_name]
    if not next_state then
        log_error("StateMgr want to change to not exist state %s", state_name)
        return
    end
    if self.active_state then
        self.active_state:exit()
    end
    self.last_state = self.active_state
    self.active_state = next_state
    self.active_state:enter(params)
end

function StateMgr:get_active_state_name()
    local ret = nil
    if self.active_state then
        ret = self.active_state:get_name()
    end
    return ret
end

function StateMgr:get_last_state_name()
    local ret = nil
    if self.last_state then
        ret = self.last_state:get_name()
    end
    return ret
end
