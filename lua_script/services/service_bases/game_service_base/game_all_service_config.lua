
GameAllServiceConfig =  GameAllServiceConfig or class("GameAllServiceConfig")

function GameAllServiceConfig.parse_file(file_path)
    local cfg = GameAllServiceConfig:new()
    local ret = cfg:parse(file_path)
    return ret and cfg or nil
end

function GameAllServiceConfig:ctor()
    self.kvs = {}
    self.etcd_services = {}
    self.service_group = {}
    self.service_names = {
        Service_Const.Etcd_Service,
        Service_Const.Mongo_Service,
        Service_Const.Platform_Service,
        Service_Const.Auth_Service,
        Service_Const.Login,
        Service_Const.Gate,
        Service_Const.World,
        Service_Const.Game,
        Service_Const.Robot,
        Service_Const.match,
        Service_Const.fight,
        Service_Const.room,
        Service_Const.redis_service,
    }
end

function GameAllServiceConfig:parse(file_path)
    local xml_cfg = xml.parse_file(file_path)
    self.kvs = xml_cfg["root"]
    for _, name in pairs(self.service_names) do
        self.service_group[name] = {}
        assert(self.kvs[name] and self.kvs[name][Service_Const.Element])
        for _, v in pairs(self.kvs[name][Service_Const.Element]) do
            if IsTable(v) then
                table.insert(self.service_group[name], v)
            end
        end
    end
    return true
end

function GameAllServiceConfig:get_game_service(zone, name, idx)
    local ret = nil
    idx = tostring(idx)
    local service_group = self.service_group[name]
    -- log_debug("GameAllServiceConfig:get_game_service zone:%s name:%s idx=%s group:%s", zone, name, idx, service_group)
    for _, v in pairs(service_group) do
        if v.zone == zone and v.idx == idx then
            ret = v
            break
        end
    end
    return ret
end

function GameAllServiceConfig:get_game_service_group(zone, name)
    local ret = {}
    local service_group = self.service_group[name]
    for _, v in pairs(service_group) do
        if v.zone == zone then
            table.insert(ret, v)
        end
    end
    return ret
end

function GameAllServiceConfig:get_third_party_service(service_name, identify_name)
    local ret = nil
    for _, v in pairs(self.service_group[service_name]) do
        if v.name == identify_name then
            ret = v
            break
        end
    end
    return ret
end

function GameAllServiceConfig:get_third_party_service_group(service_name, identify_name)
    local ret = {}
    for _, v in pairs(self.service_group[service_name]) do
        if not identify_name then
            table.insert(ret, v)
        else
            if v.name == identify_name then
                table.insert(ret, v)
            end
        end
    end
    return ret
end

function GameAllServiceConfig:get_world_service_count(zone_name)
    local world_cfg_group = self:get_game_service_group(zone_name, Service_Const.World)
    return #world_cfg_group
end
