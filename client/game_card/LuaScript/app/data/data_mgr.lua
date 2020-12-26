
---@class DataMgr:EventMgr
---@field game_user GameUser
---@field main_role MainRole
---@field fight FightData
---@field match MatchData
---@field room RoomData
DataMgr = DataMgr or class("DataMgr", EventMgr)

function DataMgr:ctor(_app)
    DataMgr.super.ctor(self)
    self._app = _app
    self._data_list = {}
end

function DataMgr:init()
    self:_add_data_base_help(GameUser)
    self:_add_data_base_help(MainRole)
    self:_add_data_base_help(FightData)
    self:_add_data_base_help(RoomData)
    self:_add_data_base_help(MatchData)

    for _, v in pairs(self._data_list) do
        v:init()
    end
end

function DataMgr:_add_data_base_help(cls)
    local data = cls:new(self)
    local data_name = data:get_name()
    assert(not self[data_name])
    assert(not self._data_list[data_name])
    self[data_name] = data
    self._data_list[data_name] = data
end

function DataMgr:release()
    for _, v in pairs(self._data_list) do
        v:release()
    end
    self:cancel_all()
end



