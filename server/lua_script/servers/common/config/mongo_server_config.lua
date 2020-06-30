
---@class MongoServerConfig
---@field name string
---@field host string
---@field user string
---@field pwd string
MongoServerConfig = MongoServerConfig or class("MongoServerConfig")

function MongoServerConfig:ctor()
    self.name = nil
    self.host = nil
    self.user = nil
    self.pwd = nil
    self.auth_db = nil
    self.thread_num = 1
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

function MongoServerConfig:parse_from(tb)
    self.name = tb.name
    self.host = tb.host
    self.user = tb.user or ""
    self.pwd = tb.pwd or ""
    self.auth_db = tb.auth_db or ""
    self.thread_num = to_num(tb.thread_num, 1)
    return true
end