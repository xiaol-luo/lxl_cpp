
---@class HttpNetServiceProxy
HttpNetServiceProxy = HttpNetServiceProxy or class("HttpNetServiceProxy")

function HttpNetServiceProxy:ctor(http_net_svc)
    ---@type RpcService
    self._http_net_svc = http_net_svc
    self._set_record = {}
end

---@param method_name string
---@param handle_fn Fn_HttpServiceHandleReq
function HttpNetServiceProxy:set_handle_fn(method_name, handle_fn)
    if handle_fn then
        assert(not self._set_record[method_name])
    end
    self._http_net_svc:set_handle_fn(method_name, handle_fn)
    self._set_record[method_name] = handle_fn and true or nil
end

function HttpNetServiceProxy:clear_all()
    for fn_name, _ in pairs(self._set_record) do
        self._http_net_svc:set_handle_fn(fn_name, nil)
    end
    self._set_record = {}
end

