
---@class ClientNetCnn
---@field netid number
ClientNetCnn = ClientNetCnn or class("ClientNetCnn")

function ClientNetCnn:ctor(client_net_svc, cnn)
    ---@type PidBinCnn
    self._cnn = cnn
    ---@type ClientNetService
    self._client_net_svc = client_net_svc
    self.netid = self._cnn:netid()
    self._pto_parser = self._client_net_svc.server.pto_parser
    self._last_touch_sec = logic_sec()
end

function ClientNetCnn:reset()
    self._cnn:reset()
end

function ClientNetCnn:touch(now_sec)
    self._last_touch_sec = now_sec or logic_sec()
end

function ClientNetCnn:idle_secs(now_sec)
    now_sec = now_sec or logic_sec()
    local ret = now_sec - self._last_touch_sec
    return ret > 0 and ret or 0
end

function ClientNetCnn:is_alive()
    return nil ~= self._cnn.native_handler
end

function ClientNetCnn:send_bin(pid, bin)
    if not self:is_alive() then
        return false
    end
    return self._cnn:send(pid, bin)
end

function ClientNetCnn:send_msg(pid, msg)
    if not self:is_alive() then
        return false
    end
    local is_ok, bin = self._pto_parser:encode(pid, msg)
    if is_ok then
        return self._cnn:send(pid, bin)
    else
        return false
    end
end