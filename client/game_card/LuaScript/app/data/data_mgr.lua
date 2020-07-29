
---@class DataMgr:EventMgr
DataMgr = DataMgr or class("DataMgr", EventMgr)

function DataMgr:ctor(_app)
    DataMgr.super.ctor(self)
    self._app = _app
end

function DataMgr:init()

end



