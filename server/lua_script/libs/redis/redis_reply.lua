
---@class RedisReply
RedisReply = RedisReply or class("RedisReply")

function RedisReply:ctor(reply)
    self._type = reply.type
    self._error_msg = nil
    self._value = reply.value
    self._status_val = nil
    self._number_val = nil
    self._array_val = nil
    self._str_val = nil

    if Redis_Reply_Type.REDIS_REPLY_ARRAY == reply.type then
        self._array_val = {}
        for _, v in ipairs(reply.value) do
            local item = RedisReply:new(v)
            table.insert(self._array_val, item)
        end
    end
    if Redis_Reply_Type.REDIS_REPLY_STRING == reply.type then
        self._str_val = reply.value
        self._number_val = tonumber(reply.value)
    end
    if Redis_Reply_Type.REDIS_REPLY_INTEGER == reply.type then
        self._str_val = reply.value
        self._number_val = tonumber(reply.value)
    end
    if Redis_Reply_Type.REDIS_REPLY_NIL == reply.type then
        self._value = nil
    end
    if Redis_Reply_Type.REDIS_REPLY_STATUS == reply.type then
        if "OK" == reply.value then
            self._status_val = true
        end

    end
    if Redis_Reply_Type.REDIS_REPLY_ERROR == reply.type then
        self._value = nil
        self._error_msg = reply.value
    end
end

function RedisReply:get_type()
    return self._type
end

function RedisReply:is_ok()
    return nil == self._error_msg
end

function RedisReply:get_error()
    return self._error_msg
end

function RedisReply:get_value()
    return self._value
end

function RedisReply:get_number()
    return self._number_val
end

function RedisReply:get_str()
    return self._str_val
end

function RedisReply:get_status()
    return self._status_val
end

function RedisReply:get_array()
    return self._array_val
end






