
---@class NetMgr:EventMgr
NetMgr = NetMgr or class("NetMgr", EventMgr)

function NetMgr:ctor(_app)
    NetMgr.super.ctor(self)
    self._app = _app
end

function NetMgr:init()

end



