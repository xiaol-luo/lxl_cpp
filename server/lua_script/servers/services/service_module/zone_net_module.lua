
ZoneNetModule = ZoneNetModule or class("ZoneNetModule", ServiceModule)

local _ErrorNum = {
    Wait_Start_Expired = 1,
}

function ZoneNetModule:ctor(module_mgr, module_name)
    ZoneNetModule.super.ctor(self, module_mgr, module_name)
    self.zone_net = nil
    self.zone_name = nil
    self.check_zone_net_ready_tid = nil
    self.Wait_Start_Max_Sec = 60
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
    self.curr_state = Service_State.Starting
    self.zone_net:start()
    local start_sec = logic_sec()
    self.timer_proxy:firm(Functional.make_closure(self._checkStartResult, self, start_sec),1 * 1000, -1)
end

function ZoneNetModule:_checkStartResult(start_sec)
    if Service_State.Starting ~= self.curr_state and Service_State.Started ~= self.curr_state then
        self:_cancel_check_zone_net_ready()
        return
    end
    self.zone_net:on_frame()
    if self.zone_net:is_ready() then
        self:_cancel_check_zone_net_ready()
        self.curr_state = Service_State.Started
    end
    if Service_State.Starting == self.curr_state then
        if logic_sec() - start_sec >= self.Wait_Start_Max_Sec then
            self:_cancel_check_zone_net_ready()
            self.error_num =_ErrorNum.Wait_Start_Expired
            self.error_num = "wait start expired"
            return
        end
    end
end

function ZoneNetModule:stop()
    self.curr_state = Service_State.Stopping
    self.zone_net:stop()
    self.timer_proxy:release_all()
    local Delay_Over_Sec_For_Zone_Service_Delete_Etcd_Key = 1
    self.timer_proxy:delay(function()
        self.curr_state = Service_State.Stopped
        self.timer_proxy:release_all()
    end, Delay_Over_Sec_For_Zone_Service_Delete_Etcd_Key * 1000)
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

function ZoneNetModule:_cancel_check_zone_net_ready()
    if self.check_zone_net_ready_tid then
        self.timer_proxy:remove(self.check_zone_net_ready_tid)
        self.check_zone_net_ready_tid = nil
    end
end