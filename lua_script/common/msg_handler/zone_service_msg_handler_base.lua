
ZoneServiceMsgHandlerbase = ZoneServiceMsgHandlerbase or class("ZoneServiceMsgHandlerbase", MsgHandlerBase)

function ZoneServiceMsgHandlerbase:ctor()
    self.super:ctor()
    self.zs_mgr = nil
end

function ZoneServiceMsgHandlerbase:init(...)
    self.super:init(...)
end

function ZoneServiceMsgHandlerbase:set_zone_service_mgr(zs_mgr)
    if zs_mgr then
        assert(not self.zs_mgr)
    end
    self.zs_mgr = zs_mgr
end

function ZoneServiceMsgHandlerbase:on_msg(pid, block, from_service)
    local ret = false
    local handle_fn = self.handle_msg_fns[pid]
    if handle_fn then
        local is_ok, msg = PROTO_PARSER:decode(pid, block)
        if is_ok then
            safe_call(handle_fn, from_service, pid, msg)
            ret = true
        else
            log_error("ZoneServiceMsgHandlerbase:on_msg decode fail, pid:%s, from service:%s", pid, from_service)
        end
    end
    return ret
end

function ZoneServiceMsgHandlerbase:send(to_service, pid, tb)
    assert(self.zs_mgr)
    local is_ok = true
    local block = nil
    if tb then
        is_ok, block = PROTO_PARSER:encode(pid, tb)
    end
    if not is_ok then
        log_error("ZoneServiceMsgHandlerbase:send encode fail, pid:%s, to service:%s, tb:%s", pid, to_service, tb)
        return false
    end
    return self.zs_mgr:send(to_service, pid, block)
end