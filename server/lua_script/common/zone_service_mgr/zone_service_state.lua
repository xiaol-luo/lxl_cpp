
ZoneServerState = ZoneServerState or class("ZoneServerState")
ZoneServerState.Const = ZoneServerState.Const or {}
ZoneServerState.Const.Id = "id"
ZoneServerState.Const.Ip = "ip"
ZoneServerState.Const.Service = "service"
ZoneServerState.Const.Port = "port"
ZoneServerState.Const.Online = "online"

function ZoneServerState:ctor(id, service, ip, port)
    self[ZoneServerState.Const.Id] = id
    self[ZoneServerState.Const.Service]= service
    self[ZoneServerState.Const.Ip]= ip
    self[ZoneServerState.Const.Port]= port
end

function ZoneServerState:set_online(val)
    self[ZoneServerState.Const.Online] = val and true or nil
end

function ZoneServerState:get_id()
    return self[ZoneServerState.Const.Id]
end

function ZoneServerState:get_ip()
    return self[ZoneServerState.Const.Ip]
end

function ZoneServerState:get_service()
    return self[ZoneServerState.Const.Service]
end

function ZoneServerState:get_port()
    return self[ZoneServerState.Const.Port]
end

function ZoneServerState:get_online()
    return self[ZoneServerState.Const.Online]
end

function ZoneServerState:to_json()
    local tb = {}
    for k, v in pairs(ZoneServerState.Const) do
        tb[v] = self[v]
    end
    local ret = rapidjson.encode(tb)
    return ret
end

function ZoneServerState.from_json(json_str)
    local ret = ZoneServerState:new(nil, nil, nil, nil)
    local tb = rapidjson.decode(json_str)
    for _, v in pairs(ZoneServerState.Const) do
        ret[v] = tb[v]
    end
    return ret
end
