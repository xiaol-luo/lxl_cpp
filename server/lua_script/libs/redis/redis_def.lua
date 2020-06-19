
---@class Redis_Reply_Type
---@field REDIS_REPLY_STRING number
---@field REDIS_REPLY_ARRAY number
---@field REDIS_REPLY_INTEGER number
---@field REDIS_REPLY_NIL number
---@field REDIS_REPLY_STATUS number
---@field REDIS_REPLY_ERROR number
Redis_Reply_Type = {
    REDIS_REPLY_STRING = 1,
    REDIS_REPLY_ARRAY = 2,
    REDIS_REPLY_INTEGER = 3,
    REDIS_REPLY_NIL = 4,
    REDIS_REPLY_STATUS = 5,
    REDIS_REPLY_ERROR = 6,
}

---@alias Fn_RedisCommandCb fun(ret:RedisResult):void