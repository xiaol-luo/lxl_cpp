ServiceBase = ServiceBase or class("ServiceBase")

function ServiceBase:ctor()
    self.timer_proxy = nil
    self.zone_name = nil
    self.service_id = nil
    self.service_name = nil
    self.service_idx = nil
    self.zone_service_mgr = nil
    self.zone_service_msg_handler = nil
    self.zone_service_rpc_mgr = nil
    self.event_mgr = nil
end

function ServiceBase:init()
    self.event_mgr = EventMgr:new()
    self.timer_proxy = TimerProxy:new()
    self.service_idx = MAIN_ARGS[MAIN_ARGS_SERVICE_IDX]
    self.service_name = MAIN_ARGS[MAIN_ARGS_SERVICE_NAME]

    local SCC = Service_Cfg_Const
    local instance_settings = ZONE_SETTING[SCC.Root][SCC.Services][self.service_name][SCC.Instance]
    local instance_setting = nil
    for _, v in pairs(instance_settings) do
        if v[SCC.Idx] == tostring(self.service_idx) then
            instance_setting = v
        end
    end
    assert(instance_setting)
    self.service_id = tonumber(instance_setting[SCC.Id])
    local listen_peer_port = instance_setting[SCC.Listen_Peer_Port]
    local etcd_setting = ZONE_SETTING[SCC.Root][SCC.Etcd]
    self.zone_name = etcd_setting[SCC.Etcd_Root_Dir]
    local etcd_host = etcd_setting[SCC.Etcd_Host]
    local etcd_usr = etcd_setting[SCC.Etcd_User]
    local etcd_pwd = etcd_setting[SCC.Etcd_Pwd]
    local etcd_ttl = etcd_setting[SCC.Etcd_Ttl]
    self.zone_service_mgr = ZoneServiceMgr:new(etcd_host, etcd_usr, etcd_pwd, etcd_ttl,
            self.zone_name, self.service_name, self.service_idx, self.service_id,
            tonumber(listen_peer_port), native.local_net_ip(), self:create_event_proxy())
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

function ServiceBase:create_event_proxy()
    local ret = EventProxy:new(self.event_mgr)
    return ret
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

