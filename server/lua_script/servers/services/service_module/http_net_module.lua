
HttpNetModule = HttpNetModule or class("HttpNetModule", ServiceModule)

function HttpNetModule:ctor(module_mgr, module_name)
    HttpNetModule.super.ctor(self, module_mgr, module_name)
    self.http_service = nil
    self.listen_port = nil
end

function HttpNetModule:init(listen_port, handle_fn_map)
    HttpNetModule.super.init(self)
    self.listen_port = listen_port
    self.http_service = HttpService:new()
    for method_name, fn in pairs(handle_fn_map) do
        self.http_service:set_handle_fn(method_name, fn)
    end
end

function HttpNetModule:start()
    self.curr_state = Service_State.Starting
    local ret = self.http_service:start(self.listen_port)
    if not ret then
        self.error_num = 1
        self.error_msg = "start fail"
        assert(false, string.format("HttpNetModule listen port %s fail", self.listen_port))
    else
        self.curr_state = Service_State.Started
    end
end

function HttpNetModule:stop()
    self.curr_state = Service_State.Stopped
    self.http_service:stop()
end


