---@class GameRoomMgr:GameLogicEntity
---@field logics GameLogicService
---@field server GameServer
GameRoomMgr = GameRoomMgr or class("GameRoomMgr", GameLogicEntity)

function GameRoomMgr:ctor(logics, logic_name)
    GameRoomMgr.super.ctor(self, logics, logic_name)
end
