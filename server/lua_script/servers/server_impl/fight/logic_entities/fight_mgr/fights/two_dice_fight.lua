
---@class TwoDiceFight:FightBase
TwoDiceFight = TwoDiceFight or class("TwoDiceFight", FightBase)

function TwoDiceFight:ctor(fight_mgr, setup_data)
    TwoDiceFight.super.ctor(self, fight_mgr, setup_data)
end

function TwoDiceFight:_on_init(...)
    -- override by subclass
end

function TwoDiceFight:_on_start()
    -- override by subclass
end

function TwoDiceFight:_on_stop()
    -- override by subclass
end

function TwoDiceFight:_on_release()
    -- override by subclass
end

function TwoDiceFight:_on_update()
    -- override by subclass
end
