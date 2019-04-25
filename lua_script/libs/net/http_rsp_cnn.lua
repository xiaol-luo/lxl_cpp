
HttpRspCnn = HttpRspCnn or class("HttpRspCnn", net_handler)

function HttpRspCnn:ctor(net_handler_map)
    self.super:ctor()
    self.native_handler = native.make_shared_http_rsp_cnn(net_handler_map:get_native_weak_ptr())
    self.native_handler:set_req_cb(Functional.make_closure(HttpRspCnn._on_req_cb, self))
    self.native_handler:set_event_cb(Functional.make_closure(HttpRspCnn._on_event_cb, self))
    self.event_cb = nil
    self.req_cb = nil
end

function HttpRspCnn:Reset()
    if self.native_handler then
        Net.close(self.native_handler:netid())
        self.native_handler = nil
    end
end

function HttpRspCnn:cnn_handler_shared_ptr()
    return native.to_connect_handler_shared_ptr(self.native_handler)
end

function HttpRspCnn:cnn_handler_weak_ptr()
    return native.to_connect_handler_weak_ptr(self.native_handler)
end

function HttpRspCnn:send(bin)
    if not self.native_handler then
        return false
    end
    local ret = self.native_handler:send(pid)
    return ret
end

function HttpRspCnn:set_event_cb(fn)
    self.event_cb = fn
end

function HttpRspCnn:set_req_cb(fn)
    self.req_cb = fn
end

function HttpRspCnn:_on_req_cb(native_cnn, method, url, heads, body, body_len)
    log_debug("HttpRspCnn:_on_req_cb xxxxxx")
    if self.req_cb then
        return self.req_cb(self, method, url, heads, body, body_len)
    else
        return false
    end
end

function HttpRspCnn:_on_event_cb(native_cnn, event_type, err_num)
    if self.event_cb then
        self.event_cb(self, event_type, err_num)
    end
end



