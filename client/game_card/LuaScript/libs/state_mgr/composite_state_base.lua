
---@class CompositeStateBase:StateBase
---@field child_state_mgr StateMgr
CompositeStateBase = CompositeStateBase or class("CompositeStateBase", StateBase)

function CompositeStateBase:ctor(state_mgr, state_name)
    CompositeStateBase.super.ctor(self, state_mgr, state_name)
    -- 进入此状态时，默认进入子状态enter_state_name
    -- 退出此状态时，默认进入子状态exit_state_name
    self.child_state_mgr = nil  -- 子状态管理器
    self.enter_state_name = nil -- 进入此状态，先进入这个子状态
    self.exit_state_name = nil  -- 退出此状态，进入此子状态
end

function CompositeStateBase:init()
    CompositeStateBase.super.init(self)
    self:_prepare_child_states()
    self.child_state_mgr:init()
end

function CompositeStateBase:release()
    self.child_state_mgr:release()
    CompositeStateBase.super.release(self)
end

function CompositeStateBase:_prepare_child_states()

end

function CompositeStateBase:on_enter(params)
    CompositeStateBase.super.on_enter(self, params)
    self.child_state_mgr:change_state(self.enter_state_name, params)
end

function CompositeStateBase:on_exit()
    CompositeStateBase.super.on_exit(self)
    self.child_state_mgr:change_state(self.exit_state_name)
end

function CompositeStateBase:on_update()
    CompositeStateBase.super.on_update(self)
    self.child_state_mgr:update_state()
end









