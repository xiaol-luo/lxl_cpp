
GameAllServiceConfig =  GameAllServiceConfig or class("GameAllServiceConfig")

local For

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
        Service_Const.Avatar,
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
    local service_group = self.service_group[name]
    for _, v in pairs(service_group) do
        if v.zone == zone and v.idx == idx then
            ret = v
            break
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

