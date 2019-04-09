
MsgHandlerBase = MsgHandlerBase or class("MsgHandlerBase")

function MsgHandlerBase:ctor()
    self.handle_msg_fns = {}
end

function MsgHandlerBase:init(...)

end

function MsgHandlerBase:set_handler_msg_fn(pid, fn)
    assert(pid and fn)
    assert(not self.handle_msg_fns[pid])
    self.handle_msg_fns[pid] = fn
end

function MsgHandlerBase:on_msg(pid, bin, ...)
    assert("should not reach here")
    local processed = false
    return processed
end

function MsgHandlerBase:send(pid, bin, ...)
    assert("should not reach here")
    return false
end