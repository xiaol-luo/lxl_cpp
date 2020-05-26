
---@class Http_Rsp_Cnn_Event
---@field Open
---@field Close
---@field Parse
Http_Rsp_Cnn_Event = {
    Open = 0,
    Close = 1,
    Parse = 2,
}

---@alias Fn_HttpRspCnnEventCB fun(event:Http_Rsp_Cnn_Event, error_num:number ):void
---@alias Fn_HttpRspCnnReqCB fun(cnn:HttpRspCnn, method:HttpMethod, url:string, heads:table<string, string>, body: string):boolean

---@class HttpRspCnn : NetCnn
HttpRspCnn = HttpRspCnn or class("HttpRspCnn", NetCnn)

function HttpRspCnn:ctor(net_handler_map)
    HttpRspCnn.super.ctor(self)
    ---@type NetHandlerMap
    self.native_handler = native.make_shared_http_rsp_cnn(net_handler_map:get_native_weak_ptr())
    self.native_handler:set_req_cb(Functional.make_closure(HttpRspCnn._on_req_cb, self))
    self.native_handler:set_event_cb(Functional.make_closure(HttpRspCnn._on_event_cb, self))
    ---@type Fn_HttpRspCnnEventCB
    self.event_cb = nil
    ---@type Fn_HttpRspCnnReqCB
    self.req_cb = nil
end

function HttpRspCnn:reset()
    HttpRspCnn.super.reset(self)
    self.event_cb = nil
    self.req_cb = nil
end

---@param fn Fn_HttpRspCnnEventCB
function HttpRspCnn:set_event_cb(fn)
    self.event_cb = fn
end

---@param fn Fn_HttpRspCnnReqCB
function HttpRspCnn:set_req_cb(fn)
    self.req_cb = fn
end

function HttpRspCnn:_on_req_cb(native_cnn , method, url, heads, body)
    if self.req_cb then
        local is_ok, ret = Functional.safe_call(self.req_cb, self, method, url, heads, body)
        return is_ok and ret or false
    end
    return false
end

function HttpRspCnn:_on_event_cb(native_cnn, event_type, error_num)
    if self.event_cb then
        Functional.safe_call(self.event_cb, self, event_type, error_num)
    end
    if Http_Rsp_Cnn_Event.Open == event_type then
        self:on_open(error_num)
    end
    if Http_Rsp_Cnn_Event.Close == event_type then
        self:on_close(error_num)
    end
end



