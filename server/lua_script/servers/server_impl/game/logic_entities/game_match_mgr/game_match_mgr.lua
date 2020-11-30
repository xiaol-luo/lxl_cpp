---@class GameMatchMgr:GameLogicEntity
---@field logics GameLogicService
---@field server GameServer
GameMatchMgr = GameMatchMgr or class("GameMatchMgr", GameLogicEntity)

function GameMatchMgr:ctor(logics, logic_name)
    GameMatchMgr.super.ctor(self, logics, logic_name)
end
