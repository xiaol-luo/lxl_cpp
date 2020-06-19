
---@class RedisResult
RedisResult = RedisResult or class("RedisResult")

function RedisResult:ctor(ret)
    -- self._ret = ret
    self._task_id = ret.task_id
    self._error_num = ret.error_num
    self._error_msg = ret.error_msg
    self._reply = RedisReply:new(ret.reply)
end

function RedisResult:get_task_id()
    return self._task_id
end

function RedisResult:get_error()
    return self._error_num, self._error_msg
end

function RedisResult:get_reply()
    return self._reply
end




