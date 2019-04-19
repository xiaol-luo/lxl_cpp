ServiceBase = ServiceBase or class("ServiceBase")

function ServiceBase:ctor()
    self.timer_proxy = nil
    self.service_idx = nil
    self.service_name = nil
    self.zone_service_mgr = nil
    self.zone_service_msg_handler = nil
    self.zone_service_rpc_mgr = nil
end

function ServiceBase:init()
    self.timer_proxy = TimerProxy:new()
    self.service_idx = MAIN_ARGS[MAIN_ARGS_SERVICE_IDX]
    self.service_name = MAIN_ARGS[MAIN_ARGS_SERVICE_NAME]

    local SCC = Service_Cfg_Const
    local instance_setting = ZONE_SETTING[SCC.Root][SCC.Services][self.service_name][SCC.Instance]
    local listen_peer_port = instance_setting[tostring(self.service_idx)][SCC.Listen_Peer_Port]
    local etcd_setting = ZONE_SETTING[SCC.Root][SCC.Etcd]
    self.zone_service_mgr = ZoneServiceMgr:new(etcd_setting, self.service_name, self.service_idx, tonumber(listen_peer_port))

    self.zone_service_msg_handler = self:create_zone_service_msg_handler()
    self.zone_service_mgr:add_msg_handler(self.zone_service_msg_handler)

    self.zone_service_rpc_mgr = self:create_zone_service_rpc_mgr()
    self.zone_service_rpc_mgr:init(self.zone_service_msg_handler)
end

function ServiceBase:create_zone_service_msg_handler()
    assert(false, "should not reach here")
end

function ServiceBase:create_zone_service_rpc_mgr()
    assert(false, "should not reach here")
end

function ServiceBase:start()
    self:start_zone_service()
    self.timer_proxy:firm(Functional.make_closure(self.on_frame, self), SERVICE_MICRO_SEC_PER_FRAME, -1)
end

function ServiceBase:stop()
    self.timer_proxy:release_all()
    self:stop_zone_service()
end

function ServiceBase:start_zone_service()
    self.zone_service_mgr:start()
end

function ServiceBase:stop_zone_service()
    self.zone_service_mgr:stop()
end

function ServiceBase:on_frame()
    self.zone_service_mgr:on_frame()
    self.zone_service_rpc_mgr:on_frame()
end

function ServiceBase:OnNotifyQuitGame()
    self:stop()
end

function ServiceBase:CheckCanQuitGame()
    return true
end

