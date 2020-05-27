
---@class ServerBase : EventMgr
---@field init_args table<string, string>
---@field init_setting table<string, string>
---@field server_role Server_Role
---@field server_name string
---@field etcd_service_discovery_setting EtcdSetting
ServerBase = ServerBase or class("ServerBase", EventMgr)

function ServerBase:ctor(server_role, init_setting, init_args)
    ServerBase.super.ctor(self)
    self.zone = nil
    self.server_role = string.lower(server_role)
    self.init_setting = init_setting
    self.init_args = init_args
    self.server_name = nil
    self.etcd_service_discovery_setting = nil
    ---@type EventBinder
    self._event_binder = EventBinder:new()
    ---@type ServiceMgrBase
    self._service_mgr = ServiceMgr:new(self)
    ---@type TimerProxy
    self._timer_proxy = TimerProxy:new()
    ---@type Server_Quit_State
    self.quit_state = Server_Quit_State.none
end

function ServerBase:init()
    local ret = self:_on_init()
    return ret
end

function ServerBase:start()
    self:_on_start()
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

function ServerBase:release()
    self:_on_release()
end

function ServerBase:_on_init()
    if self.server_role ~= string.lower(self.init_setting.server_role) then
        log_error("ServerBase:_on_init server_role=%s, but init_setting.server_role=%s, mismatch!", self.server_role, self.init_setting.server_role)
        return false
    end

    if not self.init_setting.zone then
        return false
    end
    self.zone = string.lower(self.init_setting.zone)

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

    if not self._service_mgr:init() then
        return false
    end

    return true
end

function ServerBase:_on_start()
    self._service_mgr:start()
    self._timer_proxy:firm(Functional.make_closure(self._on_frame, self), Const.service_micro_sec_per_frame, Forever_Execute_Timer)
end

function ServerBase:_on_stop()
    self._service_mgr:stop()
end

function ServerBase:_on_release()
    self._service_mgr:release()
    self._timer_proxy:release_all()
end

function ServerBase:_on_frame()
    self._service_mgr:on_frame()
    local error_num, error_msg = self._service_mgr:get_error()
    if error_num and Server_Quit_State.none == self.quit_state then
        native.try_quit_game()
        assert(error_num, error_msg)
    end
end

function ServerBase:_on_notify_quit_game()
    if Server_Quit_State.none == self.quit_state then
        self.quit_state = Server_Quit_State.quiting
        self:fire(Server_Event.Notify_Quit_Game, self)
        self:stop()
    end
end

function ServerBase:_check_can_quit_game()
    local can_quit = false
    if Service_State.Stopped == self._service_mgr:get_curr_state() then
        can_quit = true
    end
    if can_quit and Server_Quit_State.quiting == self.quit_state then
        self.quit_state = Server_Quit_State.quited
        self:release()
    else
        -- self.module_mgr:print_module_state()
    end
    return can_quit
end

function ServerBase:try_quit_game()
    native.try_quit_game()
end


