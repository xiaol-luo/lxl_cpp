
---@class HttpNetService:ServiceBase
HttpNetService = HttpNetService or class("HttpNetService", ServiceBase)


function HttpNetService:ctor(service_mgr, service_name)
    HttpNetService.super.ctor(self, service_mgr, service_name)
    self._http_service = nil
    self._listen_port = nil
end


function HttpNetService:_on_init(listen_port)
    HttpNetService.super._on_init(self)
    self._listen_port = listen_port
    self._http_service = HttpService:new()
end

function HttpNetService:_on_start()
    log_print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! HttpNetService:_on_start")
    HttpNetService.super._on_start(self)
    local ret = self._http_service:start(self._listen_port)
    if not ret then
        self.error_num = 1
        self.error_msg = string.format("HttpNetService listen port %s fail", self._listen_port)
    end
end


function HttpNetService:_on_stop()
    HttpNetService.super._on_stop(self)
    self._http_service:stop()
end

function HttpNetService:_on_release()
    HttpNetService.super._on_release(self)
    self._http_service:release()
    self._http_service = nil
end

---@param method_name string
---@param handle_fn Fn_HttpServiceHandleReq
function HttpNetService:set_handle_fn(method_name, handle_fn)
    self._http_service:set_handle_fn(method_name, handle_fn)
end

function HttpNetService:create_proxy()
    return HttpNetServiceProxy:new(self)
end


