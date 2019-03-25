
ZoneServiceState = ZoneServiceState or class("ZoneServiceState")
ZoneServiceState.Const = ZoneServiceState.Const or {}
ZoneServiceState.Const.Ip = "ip"
ZoneServiceState.Const.Service = "service"
ZoneServiceState.Const.Port = "port"
ZoneServiceState.Const.Online = "online"

function ZoneServiceState:ctor(service, ip, port)
    self[ZoneServiceState.Const.Service]= service
    self[ZoneServiceState.Const.Ip]= ip
    self[ZoneServiceState.Const.Port]= port
end

function ZoneServiceState:set_online(val)
    self[ZoneServiceState.Const.Online] = val and true or nil
end

function ZoneServiceState:get_ip()
    return self[ZoneServiceState.Const.Ip]
end

function ZoneServiceState:get_service()
    return self[ZoneServiceState.Const.Service]
end

function ZoneServiceState:get_port()
    return self[ZoneServiceState.Const.Port]
end

function ZoneServiceState:get_online()
    return self[ZoneServiceState.Const.Online]
end

function ZoneServiceState:to_json()
    local tb = {}
    for k, v in pairs(ZoneServiceState.Const) do
        tb[v] = self[v]
    end
    local ret = rapidjson.encode(tb)
    return ret
end

function ZoneServiceState.from_json(json_str)
    local tb = rapidjson.decode(json_str)
    for k, v in pairs(ZoneServiceState.Const) do
        self[v] = tb[v]
    end
end
