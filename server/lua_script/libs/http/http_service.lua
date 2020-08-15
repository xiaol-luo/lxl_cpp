
---@alias Fn_HttpServiceHandleReq fun(from_cnn_id:number, method:HttpMethod, req_url:string, heads_map:table<string, string>, body:string):boolean

---@class HttpService
HttpService = HttpService or class("HttpService")

function HttpService:ctor()
    self.listener = nil
    ---@type table<string, Fn_HttpServiceHandleReq>
    self.fn_map = {}
end

function HttpService:start(port)
    -- self.listener = native.make_shared_common_listener()
    self.listener = NetListen:new()
    self.net_handler_map = CnnHandlerMap:new()
    self.listener:set_gen_cnn_cb(Functional.make_closure(HttpService.do_gen_cnn_handler, self))
    self.listener:set_open_cb(Functional.make_closure(HttpService.on_listener_open, self))
    self.listener:set_close_cb(Functional.make_closure(HttpService.on_listener_close, self))
    self.listener_netid = Net.listen("0.0.0.0", port, self.listener)
    --[[
    self:set_handle_fn("/index", function (...)
        return gen_http_rsp_content(200, "OK", "hello world", nil)
    end)
    ]]
    return 0 ~= self.listener_netid
end

function HttpService:stop()
    Net.close(self.listener_netid)
    self.listener = nil
end

function HttpService:release()
    self:stop()
    self.fn_map = {}
end

---@param method_name string
---@param handle_fn Fn_HttpServiceHandleReq
function HttpService:set_handle_fn(method_name, handle_fn)
    assert(method_name)
    if nil ~= handle_fn then
        assert(nil == self.fn_map[method_name])
    end
    self.fn_map[method_name] = handle_fn
end

---@param net_listen NetListen
---@param error_num number
function HttpService:on_listener_open(net_listen, error_num)
    log_debug("HttpService:on_listener_open error_num:%s", error_num)
end

---@param net_listen NetListen
---@param error_num number
function HttpService:on_listener_close(net_listen, error_num)
    log_debug("HttpService:on_listener_close error_num:%s", error_num)
end

---@param net_listen NetListen
---@return HttpRspCnn
function HttpService:do_gen_cnn_handler(net_listen)
    local cnn = HttpRspCnn:new(self.net_handler_map)
    cnn:set_req_cb(Functional.make_closure(HttpService.handle_req, self))
    cnn:set_event_cb(Functional.make_closure(HttpService.handle_event, self))
    cnn:set_open_cb(function(cnn, error_num)
        -- log_debug("HttpService cnn set_open_cb cnn count is %s", self.net_handler_map:size())
    end)
    cnn:set_close_cb(function(cnn, error_num)
        -- log_debug("HttpService cnn set_close_cb cnn count is %s", self.net_handler_map:size())
    end)
    return cnn
end

---@param cnn HttpRspCnn
---@param method HttpMethod
---@param req_url string
---@param kv_params table<string, string>
---@param body string
function HttpService:handle_req(cnn, method, req_url, kv_params, body)
    local beg_pos= string.find(req_url, "?", 1, true)
    if beg_pos then
        local param_str = string.sub(req_url, beg_pos + 1)
        req_url = string.lrtrim(string.sub(req_url, 1, beg_pos - 1), " ")
        for _, kv_str in pairs(string.split(param_str, '&')) do
            local kv_array = string.split(kv_str, "=")
            if #kv_array >= 2 then
                local key = string.lrtrim(kv_array[1], " ")
                local val = string.lrtrim(kv_array[2], " ")
                if key and #key > 0 then
                    kv_params[key] = val
                end
            end
        end
    end
    if not req_url or #req_url <= 0 or req_url == "/" then
        req_url = "/index"
    end

    local cnn_id = cnn:netid()
    local is_processed = false
    local rsp_content = ""
    local process_fn = self.fn_map[req_url]
    if process_fn then
        is_processed = safe_call(process_fn, cnn_id, method, req_url, kv_params, body)
        if not is_processed then
            rsp_content = gen_http_rsp_content(500, "ServerInternalEorror", nil, nil)
        end
    else
        rsp_content = gen_http_rsp_content(404, "NoMethod", nil, nil)
    end
    if not is_processed then
        Net.send(cnn_id, rsp_content)
        Net.close(cnn_id)
    end
    return true
end

---@param cnn HttpRspCnn
---@param event_name Http_Rsp_Cnn_Event
---@param error_num number
function HttpService:handle_event(cnn, event_name, error_num)

end

function gen_http_rsp_content(state_code, state_str, body_str, heads_map)
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
    -- log_debug("gen_http_rsp_content:\n%s", ret)
    return ret
end

