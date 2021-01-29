
---@class ClientNetService: ServiceBase
ClientNetService = ClientNetService or class("ClientNetService", ServiceBase)

function ClientNetService:ctor(service_mgr, service_name)
    ClientNetService.super.ctor(self, service_mgr, service_name)
    self._listen_handler = nil
    self._listen_port = nil
    self._tolerate_cnn_idle_secs = 15
    self._last_check_cnn_expire_sec = 0
    self._cnn_map = {}
    ---@type ClientNetServiceCnnCallback
    self._cnn_cbs = nil
end

function ClientNetService:_on_init(listen_port)
    ClientNetService.super._on_init(self)
    assert(is_number(listen_port))
    self._listen_port = listen_port
end

---@param val ClientNetServiceCnnCallback
function ClientNetService:set_cnn_cbs(val)
    if is_table(val) then
        self._cnn_cbs = val
    end
end

function ClientNetService:set_tolerate_cnn_idle_secs(val)
    if is_number(val) and val > 0 then
        self._tolerate_cnn_idle_secs = val
    end
end

function ClientNetService:_on_start()
    ClientNetService.super._on_start(self)
    self._listen_handler = NetListen:new()
    self._listen_handler:set_gen_cnn_cb(Functional.make_closure(self._listen_handler_gen_cnn, self))
    self._listen_handler:set_open_cb(Functional.make_closure(self._listen_handler_on_open, self))
    self._listen_handler:set_close_cb(Functional.make_closure(self._listen_handler_on_close, self))
    local ret = Net.listen("0.0.0.0", self._listen_port, self._listen_handler)
    if ret <= 0 then
        self._error_msg = 1
        self._error_msg = string.format("ClientNetService listen prot %s fail", self._listen_port)
    end
    log_debug("ClientNetService:_on_start listen port %s ret %s", self._listen_port, ret)
end

function ClientNetService:_on_stop()
    ClientNetService.super._on_stop(self)
    if self._listen_handler then
        Net.close(self._listen_handler:netid())
        self._listen_handler = nil
    end
    for _, client_net_cnn in pairs(self._cnn_map) do
        client_net_cnn:reset()
    end
end

function ClientNetService:_on_update()
    ClientNetService.super._on_update(self)
end

function ClientNetService:_check_expire_client_net_cnns()
    local now_sec = logic_sec()
    local check_span = math.ceil(self._tolerate_cnn_idle_secs / 3.0)
    if now_sec - self._last_check_cnn_expire_sec < check_span then
        return
    end
    self._last_check_cnn_expire_sec = now_sec

    for _, client_net_cnn in pairs(self._cnn_map) do
        if client_net_cnn:idle_secs(now_sec) >= self._tolerate_cnn_idle_secs then
            client_net_cnn:reset()
        end
    end
end

---@return ClientNetCnn
function ClientNetService:get_cnn(netid)
    local ret = self._cnn_map[netid]
    return ret
end

function ClientNetService:close_cnn(netid)
    local cnn = self._cnn_map[netid]
    if cnn then
        cnn:reset()
    end
end

---@param cnn PidBinCnn
function ClientNetService:_cnn_handler_on_open(cnn, error_num)
    local netid = cnn:netid()
    if Error_None == error_num then
        local client_net_cnn = ClientNetCnn:new(self, cnn)
        self._cnn_map[netid] = client_net_cnn
        client_net_cnn:touch()

        if self._cnn_cbs and self._cnn_cbs.on_open then
            self._cnn_cbs.on_open(self, netid)
        end
    end
    -- log_debug("ClientNetService:_cnn_handler_on_open netid %s error_num %s", netid, error_num)
end

---@param cnn PidBinCnn
function ClientNetService:_cnn_handler_on_close(cnn, error_num)
    -- should override by subclass
    local netid = cnn:netid()
    local client_net_cnn = self._cnn_map[netid]
    if client_net_cnn then
        self._cnn_map[netid] = nil
        client_net_cnn:reset()

        if self._cnn_cbs and self._cnn_cbs.on_close then
            self._cnn_cbs.on_close(self, netid, error_num)
        end
    end
    cnn:reset()
    -- log_debug("ClientNetService:_cnn_handler_on_close netid %s error_num %s", netid, error_num)
end

---@param cnn PidBinCnn
function ClientNetService:_cnn_handler_on_recv(cnn, pid, bin)
    local netid = cnn:netid()
    local client_net_cnn = self._cnn_map[netid]
    if client_net_cnn then
        client_net_cnn:touch()
        if self._cnn_cbs and self._cnn_cbs.on_recv then
            self._cnn_cbs.on_recv(self, netid, pid, bin)
        end
    end
end

function ClientNetService:_listen_handler_on_open(listen_handler, error_num)
    log_debug("ClientNetService:_listen_handler_on_open %s", error_num)
end

function ClientNetService:_listen_handler_on_close(listen_handler, error_num)
    log_debug("ClientNetService:_listen_handler_on_close %s", error_num)
end

function ClientNetService:_listen_handler_gen_cnn(listen_handler)
    local cnn = PidBinCnn:new()
    cnn:set_open_cb(Functional.make_closure(self._cnn_handler_on_open, self))
    cnn:set_close_cb(Functional.make_closure(self._cnn_handler_on_close, self))
    cnn:set_recv_cb(Functional.make_closure(self._cnn_handler_on_recv, self))
    return cnn
end
