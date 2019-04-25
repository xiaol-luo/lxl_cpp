
HttpService = HttpService or class("HttpService")

function HttpService:ctor()
    self.listener = nil
    self.fn_map = {}
end

local make_cb = Functional.make_closure

function HttpService:start(port)
    -- self.listener = native.make_shared_common_listener()
    self.listener = NetListen:new()
    self.net_handler_map = CnnHandlerMap:new()
    self.listener:set_gen_cnn_cb(Functional.make_closure(HttpService.do_gen_cnn_handler, self))
    self.listener:set_open_cb(Functional.make_closure(HttpService.on_listener_open, self))
    self.listener:set_open_cb(Functional.make_closure(HttpService.on_listener_close, self))
    self.listener_netid = Net.listen("0.0.0.0", port, self.listener)
    return 0 ~= self.listener_netid
end

function HttpService:stop()
    Net.close(self.listener_netid)
    self.listener = nil
end

function HttpService:set_handle_fn(method_name, handle_fn)
    if nil ~= method_name then
        self.fn_map[method_name] = handle_fn
    end
end

function HttpService:on_listener_open(native_listener_ptr, err_num)
    log_debug("HttpService:on_listener_open err_num:%s", err_num)
end

function HttpService:on_listener_close(native_listener_ptr, err_num)
    log_debug("HttpService:on_listener_close err_num:%s", err_num)
end

function HttpService:do_gen_cnn_handler(native_listener)
    local cnn = HttpRspCnn:new(self.net_handler_map)
    cnn:set_req_cb(make_cb(HttpService.handle_req, self))
    cnn:set_event_cb(make_cb(HttpService.handle_event, self))
    return cnn
end

function HttpService:handle_req(cnn, enum_method, req_url, heads_map, body, body_size)
    print("-------------------------- HttpService:handle_req", enum_method, req_url, body, body_size)

    for k, v in pairs(heads_map) do
        print("++++++++++++++++", k, "=", v)
    end

    local ret = gen_http_rsp_content(200, "OK", heads_map, body)
    -- Net.send(native_cnn_ptr:netid(), ret)
    -- return true
    return false
end

function HttpService:handle_event(cnn, act, err_num)

end

function gen_http_rsp_content(state_code, state_msg, heads_map, body_str)
    local State_Line_Format = "HTTP/1.1 %s %s\r\n"
    local Head_Line_Format = "%s:%s\r\n"
    local Const_Content_Length = string.lower("Content-Length")

    local state_line = string.format(State_Line_Format, state_code, state_msg)
    local head_list = {}
    if heads_map then
        for k, v in pairs(heads_map) do
            if not string.lower(k) == Const_Content_Length then
                table.insert(head_list, string.format(Head_Line_Format, k, v))
            end
        end
    end
    if body_str then
        table.insert(head_list, string.format(Head_Line_Format, Const_Content_Length, #body_str))
    end
    local ret = string.format("%s%s\r\n%s", state_line, table.concat(head_list, "\r\n"), body_str or "")
    log_debug("gen_http_rsp_content %s", ret)
    return ret
end

