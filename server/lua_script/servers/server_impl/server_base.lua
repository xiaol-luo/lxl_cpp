
---@class ServerBase : EventMgr
---@field init_args table<string, string>
---@field init_setting table<string, string>
---@field server_role Server_Role
---@field server_name string
---@field etcd_service_discovery_setting EtcdSetting
ServerBase = ServerBase or class("ServerBase", EventMgr)

function ServerBase:ctor(server_role, init_setting, init_args)
    ServerBase.super.ctor(self)
    self.server_role = server_role
    self.init_setting = init_setting
    self.init_args = init_args
    self.server_name = nil
    self.etcd_service_discovery_setting = nil
    ---@type EventBinder
    self._event_binder = EventBinder:new()
end

function ServerBase:init()
    local ret = self:_on_init()
    return ret
end

function ServerBase:start()
    local ret = self:_on_start()
    return ret
end

function ServerBase:stop()
    self:_on_stop()
end

function ServerBase:notify_quit_game()
    self:_on_notify_quit_game()
end

function ServerBase:check_can_quit_game()
    local ret = self:_check_can_quit_game()
    return ret
end

function ServerBase:_on_init()
    if self.server_role ~= string.lower(self.init_setting.server_role) then
        log_error("ServerBase:_on_init server_role=%s, but init_setting.server_role=%s, mismatch!", self.server_role, self.init_setting.server_role)
        return false
    end

    if not self.init_setting.server_name then
        return false
    end
    self.server_name = string.lower(self.init_setting.server_name)

    for _, v in ipairs(self.init_setting.etcd_server.element) do
        if is_table(v) and v.name == Const.service_discovery  then
            self.etcd_service_discovery_setting = {}
            self.etcd_service_discovery_setting.host = v.host
            self.etcd_service_discovery_setting.user = v.user or ""
            self.etcd_service_discovery_setting.pwd = v.pwd or ""
        end
    end
    if not self.etcd_service_discovery_setting or not self.etcd_service_discovery_setting.host then
        return false
    end

    return true
end

function ServerBase:_on_start()
    return true
end

function ServerBase:_on_stop()

end

function ServerBase:_on_notify_quit_game()

end

function ServerBase:_check_can_quit_game()
    return true
end
