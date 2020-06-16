
---@class EtcdServerConfig
---@field name string
---@field host string
---@field user string
---@field pwd string
EtcdServerConfig = EtcdServerConfig or class("EtcdServerConfig")

function EtcdServerConfig:ctor()
    self.name = nil
    self.host = nil
    self.user = nil
    self.pwd = ""
end

function EtcdServerConfig:parse_from(tb)
    self.name = tb.name
    self.host = tb.host
    self.user = tb.user or ""
    self.pwd = tb.pwd or ""
    return true
end