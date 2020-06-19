
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

local to_num = function(input, default_val)
    if nil ~= input then
        if is_number(input) then
            return input
        elseif is_string(input) and #input > 0 then
            return tonumber(input)
        end
    end
    return default_val
end

function RedisServerConfig:parse_from(tb)
    self.name = tb.name
    self.host = tb.host
    self.is_cluster = (1 == to_num(tb.is_cluster, 0))
    self.pwd = tb.pwd or ""
    self.thread_num = to_num(tb.thread_num, 1)
    self.cnn_timeout_ms = to_num(tb.cnn_timeout_ms, 3000)
    self.cmd_timeout_ms = to_num(tb.cmd_timeout_ms, 3000)
    return true
end

