
HttpRspCnn = HttpRspCnn or class("HttpRspCnn", NetCnn)

function HttpRspCnn:ctor(net_handler_map)
    HttpRspCnn.super.ctor(self)
    self.native_handler = native.make_shared_http_rsp_cnn(net_handler_map:get_native_weak_ptr())
    self.native_handler:set_req_cb(Functional.make_closure(HttpRspCnn._on_req_cb, self))
    self.native_handler:set_event_cb(Functional.make_closure(HttpRspCnn._on_event_cb, self))
    self.event_cb = nil
    self.req_cb = nil
end

function HttpRspCnn:reset()
    HttpRspCnn.super.reset(self)
    self.event_cb = nil
    self.req_cb = nil
end

function HttpRspCnn:set_event_cb(fn)
    self.event_cb = fn
end

function HttpRspCnn:set_req_cb(fn)
    self.req_cb = fn
end

function HttpRspCnn:_on_req_cb(native_cnn, method, url, heads, body, body_len)
    if self.req_cb then
        local is_ok, ret = Functional.safe_call(self.req_cb, self, method, url, heads, body, body_len)
        return is_ok and ret or false
    end
    return false
end

function HttpRspCnn:_on_event_cb(native_cnn, event_type, err_num)
    if self.event_cb then
        Functional.safe_call(self.event_cb, event_type, err_num)
    end
end



