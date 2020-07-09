
---@class GameLogicService:LogicServiceBase
GameLogicService = GameLogicService or class("LogicService", LogicServiceBase)

function GameLogicService:_on_init()
    GameLogicService.super._on_init(self)

    do
        local logic = RoleStateMgr:new(self, Game_Logic_Name.role_mgr)
        logic:init()
        self:add_logic(logic)
    end

end