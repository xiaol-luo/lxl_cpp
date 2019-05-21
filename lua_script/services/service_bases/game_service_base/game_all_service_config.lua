
GameAllServiceConfig =  GameAllServiceConfig or class("GameAllServiceConfig")

local For

function GameAllServiceConfig.parse_file(file_path)
    local cfg = GameAllServiceConfig:new()
    local ret = cfg:parse(file_path)
    return ret and cfg or nil
end

function GameAllServiceConfig:cotr()
    self.kvs = {}
    self.etcd_services = {}

end

function GameAllServiceConfig:parse(file_path)
    local xml_cfg = xml.parse_file(file_path)
    self.kvs = xml_cfg["root"]
    log_debug("xxxxxxxxxx %s", xml_cfg)
    return true
end

function GameAllServiceConfig:get_game_service(zone, name, idx)
    local ret = nil
    local service_group = self.kvs[name]
    if service_group then
        for _, v in pairs(service_group) do
            if v.zone == zone and v.idx == idx then
                ret = v
                break
            end
        end
    end
    return ret
end

function GameAllServiceConfig:get_etcd_cfg(zone)
    local ret = nil
    for _, v in pairs(self.kvs["etcd_service"]) do
        if v.name == zone then
            ret = v
            break
        end
    end
    return ret
end

