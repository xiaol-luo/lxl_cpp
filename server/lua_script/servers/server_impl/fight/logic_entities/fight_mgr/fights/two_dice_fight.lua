
---@class TwoDiceFight:FightBase
TwoDiceFight = TwoDiceFight or class("TwoDiceFight", FightBase)

function TwoDiceFight:ctor(fight_mgr, setup_data)
    TwoDiceFight.super.ctor(self, fight_mgr, setup_data)
end

function TwoDiceFight:_on_init(...)
    TwoDiceFight.super._on_init(self)
end

function TwoDiceFight:_on_start()
    TwoDiceFight.super._on_start(self)
end

function TwoDiceFight:_on_stop()
    TwoDiceFight.super._on_stop(self)
end

function TwoDiceFight:_on_release()
    TwoDiceFight.super._on_release(self)
end

function TwoDiceFight:_on_update()
    TwoDiceFight.super._on_update(self)
end

function TwoDiceFight:_on_opera(fight_role, msg)
    -- override by subclass
    return Error_None
end

---@param fight_client FightClient
function TwoDiceFight:sync_fight_state(fight_client)
    -- override by subclass
end