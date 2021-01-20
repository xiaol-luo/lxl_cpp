
---@class GamePlayBase:EventMgr
---@field fight_logic FightLogic
GamePlayBase = GamePlayBase or class("GamePlayBase", EventMgr)

function GamePlayBase:ctor(fight_logic, game_name)
    GamePlayBase.super.ctor(self)
    self.fight_logic = fight_logic
    self._event_binder = EventBinder:new()
    self._timer_proxy = TimerProxy:new()
    self._game_name = game_name
    ---@type Game_Play_State
    self._game_state = Game_Play_State.idle
    self._next_seq = 0
end

function GamePlayBase:init(setup_data)
    self:_on_init(setup_data)
    self._game_state = Game_Play_State.pause
end

function GamePlayBase:resume()
    log_print("GamePlayBase:resume ", Game_Play_State.pause == self._game_state)
    if Game_Play_State.pause == self._game_state then
        self._game_state = Game_Play_State.resume
        self:_on_resume()
    end
end

function GamePlayBase:pause()
    if Game_Play_State.resume == self._game_state then
        self._game_state = Game_Play_State.pause
        self:_on_pause()
    end
end

function GamePlayBase:release()
    if Game_Play_State.release ~= self._game_state then
        self._game_state = Game_Play_State.release
    end
    self._event_binder:release_all()
    self._timer_proxy:release_all()
    self:cancel_all()
    self:_on_release()
end

function GamePlayBase:_on_init(setup_data)
    -- override by subclass
end

function GamePlayBase:_on_resume()
    -- override by subclass
end

function GamePlayBase:_on_pause()
    -- override by subclass
end

function GamePlayBase:_on_release()
    -- override by subclass
end

function GamePlayBase:get_name()
    return self._game_name
end

function GamePlayBase:get_state()
    return self._game_state
end

function GamePlayBase:is_release()
    return Game_Play_State.release == self._game_state
end

function GamePlayBase:is_resume()
    return Game_Play_State.resume  == self._game_state
end

function GamePlayBase:is_pause()
    return Game_Play_State.pause  == self._game_state
end

function GamePlayBase:id_idle()
    return Game_Play_State.idle  == self._game_state
end

function GamePlayBase:next_seq()
    self._next_seq = self._next_seq + 1
    return self._next_seq
end




