
---@class StateBase
---@field state_mgr StateMgr
---@field state_name string
---@field event_binder EventBinder
StateBase = StateBase or class("StateBase")

function StateBase:ctor(state_mgr, state_name)
    self.state_mgr = state_mgr
    self.state_name = state_name
    self.event_binder = EventBinder:new()
end

function StateBase:init()

end

function StateBase:release()

end

function StateBase:get_name()
    return self.state_name
end

function StateBase:get_mgr()
    return self.state_mgr
end

function StateBase:enter(params)
    log_debug("enter state %s", self:get_name())
    self:on_enter(params)
end

function StateBase:exit()
    self:on_exit()
    log_debug("exit state %s", self:get_name())
    self.event_binder:release_all()
end

function StateBase:update()
    self:on_update()
end

function StateBase:on_enter(params)

end

function StateBase:on_exit()

end

function StateBase:on_update()

end





