
ZoneNetModule = ZoneNetModule or class("ZoneNetModule", ServiceModule)

function ZoneNetModule:ctor(module_mgr, module_name)
    ZoneNetModule.super.ctor(self, module_mgr, module_name)
    self.zone_net = nil
end

function ZoneNetModule:init(etcd_host, etcd_usr, etcd_pwd, etcd_ttl, zone_name, service_name, service_idx, service_id, listen_port, listen_ip)
    ZoneNetModule.super.init(self)
    self.zone_net = ZoneServiceMgr:new(
            etcd_host, etcd_usr, etcd_pwd, etcd_ttl,
            zone_name, service_name, service_idx, service_id,
            listen_port, listen_ip, self.event_proxy)
end

function ZoneNetModule:add_msg_handler(msg_handler)
    self.zone_net:add_msg_handler(msg_handler)
end

function ZoneNetModule:remove_msg_handler(msg_handler)
    self.zone_net:remove_msg_handler(msg_handler)
end

function ZoneNetModule:send_by_id(service_id, pid, bin)
    if not self.zone_net then
        return false
    end
    return self.zone_net:send_by_id(service_id, pid, bin)
end

function ZoneNetModule:send(service_name, pid, bin)
    if not self.zone_net then
        return false
    end
    return self.zone_net:send(service_name, pid, bin)
end

function ZoneNetModule:start()
    self.curr_state = ServiceModuleState.Started
    self.zone_net:start()
end

function ZoneNetModule:stop()
    self.curr_state = ServiceModuleState.Stopped
    self.zone_net:stop()
end

function ZoneNetModule:release()
    self.curr_state = ServiceModuleState.Released
end

function ServiceModule:on_update()
    self.zone_net:on_frame()
end
