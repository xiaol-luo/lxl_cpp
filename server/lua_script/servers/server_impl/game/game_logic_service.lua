
---@class GameLogicService:LogicServiceBase
GameLogicService = GameLogicService or class("LogicService", LogicServiceBase)

function GameLogicService:_on_init()
    GameLogicService.super._on_init(self)

    do
        local logic = GameRoleMgr:new(self, Game_Logic_Name.role_mgr)
        logic:init()
        self:add_logic(logic)
    end

    do
        local logic = GameForwardMsg:new(self, Game_Logic_Name.forward_msg)
        logic:init()
        self:add_logic(logic)
    end

end