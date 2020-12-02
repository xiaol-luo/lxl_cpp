
---@class GameLogicService:LogicServiceBase
---@field role_mgr GameRoleMgr
---@field forward_msg GameForwardMsg
---@field match_mgr GameMatchMgr
---@field room_mgr GameRoomMgr
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

    do
        local logic = GameMatchMgr:new(self, Game_Logic_Name.match_mgr)
        logic:init()
        self:add_logic(logic)
    end

    do
        local logic = GameRoomMgr:new(self, Game_Logic_Name.room_mgr)
        logic:init()
        self:add_logic(logic)
    end

end