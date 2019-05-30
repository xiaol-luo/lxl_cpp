
ZoneNetModule = ZoneNetModule or class("ZoneNetModule", ServiceModule)

function ZoneNetModule:ctor(module_mgr, module_name)
    ZoneNetModule.super.ctor(self, module_mgr, module_name)
    self.zone_net = nil
    self.zone_name = nil
end

function ZoneNetModule:init(etcd_host, etcd_usr, etcd_pwd, etcd_ttl, zone_name, service_name, service_idx, service_id, listen_port, listen_ip)
    ZoneNetModule.super.init(self)
    self.zone_name = string.lrtrim(zone_name, "/")
    self.zone_net = ZoneServiceMgr:new(
            etcd_host, etcd_usr, etcd_pwd, etcd_ttl,
            zone_name, service_name, service_idx, service_id,
            listen_port, listen_ip, self.event_proxy)
    assert(self.zone_net)
end

function ZoneNetModule:get_zone_name()
    return self.zone_name
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

function ZoneNetModule:on_update()
    self.zone_net:on_frame()
end

function ZoneNetModule:get_service(service_name, service_idx)
    local ret = self.zone_net:get_peer_service(service_name, service_idx)
    return ret
end

function ZoneNetModule:get_service_group(service_name)
    local ret = self.zone_net:get_peer_service_group(service_name)
    return ret
end

function ZoneNetModule:rand_service(service_name)
    local ret = self.zone_net:rand_peer_service(service_name)
    return ret
end
