
---@class DataMgr:LuaAppLogicBase
---@field game_user GameUser
---@field main_role MainRole
---@field fight FightData
---@field match MatchData
---@field room RoomData
DataMgr = DataMgr or class("DataMgr", LuaAppLogicBase)

function DataMgr:ctor(_app)
    DataMgr.super.ctor(self)
    self._app = _app
    ---@type table<string, DataBase>
    self._data_list = {}

    self:_add_data_base_help(GameUser)
    self:_add_data_base_help(MainRole)
    self:_add_data_base_help(FightData)
    self:_add_data_base_help(RoomData)
    self:_add_data_base_help(MatchData)
end

function DataMgr:_on_init()
    DataMgr.super._on_init(self)
    for _, v in pairs(self._data_list) do
        v:init()
    end
end

function DataMgr:_on_start()
    DataMgr.super._on_init(self)
    for _, v in pairs(self._data_list) do
        v:start()
    end
end

function DataMgr:_on_stop()
    DataMgr.super._on_init(self)
    for _, v in pairs(self._data_list) do
        v:stop()
    end
end

function DataMgr:_on_release()
    DataMgr.super._on_release(self)
    for _, v in pairs(self._data_list) do
        v:release()
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




