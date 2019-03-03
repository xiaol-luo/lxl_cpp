
HttpService = HttpService or class("HttpService")

function HttpService:ctor()
    self.listener = nil
    self.fn_map = {}
end

local make_cb = Functional.make_closure

function HttpService:start(port)
    self.listener = native.make_shared_common_listener()
    local listener_cbs = native.CommonListenCallback:new()
    listener_cbs.on_add_cnn = nil
    listener_cbs.on_remove_cnn = nil
    listener_cbs.on_open = nil
    listener_cbs.on_close = nil
    listener_cbs.do_gen_cnn_handler = make_cb(HttpService.do_gen_cnn_handler, self)
    self.listener:set_cb(listener_cbs)
    local netid = native.net_listen("0.0.0.0", port, native.to_weak_ptr_net_listen(self.listener))
    return 0 ~= netid
end

function HttpService:stop()
    self.listener = nil
end

function HttpService:set_handle_fn(method_name, handle_fn)
    if nil ~= method_name then
        self.fn_map[method_name] = handle_fn
    end
end

function HttpService:do_gen_cnn_handler(native_listener)
    local cnn = native.make_shared_http_rsp_cnn(native_listener:get_cnn_map())
    cnn:set_req_cb(make_cb(HttpService.handle_req, self))
    cnn:set_event_cb(make_cb(HttpService.handle_event, self))
    return native.to_shared_ptr_net_connect(cnn)
end

function HttpService:handle_req(native_cnn_ptr, enum_method, req_url, heads_map, body, body_size)
    print("-------------------------- HttpService:handle_req", enum_method, req_url, body, body_size)

    for k, v in pairs(heads_map) do
        print("++++++++++++++++", k, "=", v)
    end
    return false
end

function HttpService:handle_event(native_cnn_ptr, act, err_num)
end

