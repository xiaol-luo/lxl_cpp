
---@class RedisServerConfig
---@field name string
---@field is_cluster number
---@field pwd string
---@field thread_num number
---@field cnn_timeout_ms number
---@field cmd_timeout_ms number
RedisServerConfig = RedisServerConfig or class("RedisServerConfig")

function RedisServerConfig:ctor()
    self.name = nil
    self.host = nil
    self.is_cluster = false
    self.pwd = ""
    self.thread_num = 0
    self.cnn_timeout_ms = 0
    self.cmd_timeout_ms = 0
end

function RedisServerConfig:parse_from(tb)
    self.name = tb.name
    self.host = tb.host
    self.is_cluster = tb.is_cluster
    self.pwd = tb.pwd or ""
    self.thread_num = tb.thread_num or 1
    self.cnn_timeout_ms = tb.cnn_timeout_ms or 3000
    self.cmd_timeout_ms = tb.cmd_timeout_ms or 3000
    return true
end

