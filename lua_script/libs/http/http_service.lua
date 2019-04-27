
HttpService = HttpService or class("HttpService")

function HttpService:ctor()
    self.listener = nil
    self.fn_map = {}
end

function HttpService:start(port)
    -- self.listener = native.make_shared_common_listener()
    self.listener = NetListen:new()
    self.net_handler_map = CnnHandlerMap:new()
    self.listener:set_gen_cnn_cb(Functional.make_closure(HttpService.do_gen_cnn_handler, self))
    self.listener:set_open_cb(Functional.make_closure(HttpService.on_listener_open, self))
    self.listener:set_open_cb(Functional.make_closure(HttpService.on_listener_close, self))
    self.listener_netid = Net.listen("0.0.0.0", port, self.listener)
    --[[
    self:set_handle_fn("/index", function (...)
        return gen_http_rsp_content(200, "OK", nil, "hello world")
    end)
    ]]
    return 0 ~= self.listener_netid
end

function HttpService:stop()
    Net.close(self.listener_netid)
    self.listener = nil
end

function HttpService:set_handle_fn(method_name, handle_fn)
    if nil ~= method_name then
        -- heandle_fn = function(enum_method, req_url, heads_map, body, body_len)
        self.fn_map[method_name] = handle_fn
    end
end

function HttpService:on_listener_open(net_listen, err_num)
    log_debug("HttpService:on_listener_open err_num:%s", err_num)
end

function HttpService:on_listener_close(net_listen, err_num)
    log_debug("HttpService:on_listener_close err_num:%s", err_num)
end

function HttpService:do_gen_cnn_handler(net_listen)
    local cnn = HttpRspCnn:new(self.net_handler_map)
    cnn:set_req_cb(Functional.make_closure(HttpService.handle_req, self))
    cnn:set_event_cb(Functional.make_closure(HttpService.handle_event, self))
    return cnn
end

function HttpService:handle_req(cnn, enum_method, req_url, heads_map, body, body_len)
    if not req_url or #req_url <= 0 or req_url == "/" then
        req_url = "/index"
    end
    local rsp_content = ""
    local process_fn = self.fn_map[req_url]
    if process_fn then
        local is_ok = false
        is_ok, rsp_content = safe_call(process_fn, enum_method, req_url, heads_map, body, body_len)
        if not is_ok then
            rsp_content = gen_http_rsp_content(500, "ServerInternalEorror", nil, nil)
        end
    else
        rsp_content = gen_http_rsp_content(404, "NoMethod", nil, nil)
    end
    Net.send(cnn:netid(), rsp_content)
    Net.close(cnn:netid())
    return true
end

function HttpService:handle_event(cnn, act, err_num)

end

function gen_http_rsp_content(state_code, state_str, heads_map, body_str)
    -- log_debug("gen_http_rsp_content %s %s %s %s", state_code, state_msg, heads_map, body_str)
    local State_Line_Format = "HTTP/1.1 %s %s\r\n"
    local Head_Line_Format = "%s:%s\r\n"
    local Const_Content_Length = string.lower("Content-Length")

    local state_line = string.format(State_Line_Format, state_code, state_str)
    local head_list = {}
    if heads_map then
        for k, v in pairs(heads_map) do
            if string.lower(k) ~= Const_Content_Length then
                table.insert(head_list, string.format(Head_Line_Format, k, v))
            end
        end
    end
    if body_str then
        table.insert(head_list, string.format(Head_Line_Format, Const_Content_Length, #body_str))
    end
    local heads_content = table.concat(head_list, "")
    local ret = string.format("%s%s\r\n%s", state_line, heads_content, body_str or "")
    log_debug("gen_http_rsp_content %s", ret)
    return ret
end

