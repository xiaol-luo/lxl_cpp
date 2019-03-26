
ServiceMain = ServiceMain or {}

local zone_service_mgr = nil
local on_frame_timeid = nil

function ServiceMain.start()
    local require_files = require("services.avatar.avatar_service_files")
    for _, v in ipairs(require_files) do
        require(v)
    end

    local service_id = tostring(MAIN_ARGS[MAIN_ARGS_SERVICE_ID])
    local SCC = Service_Cfg_Const
    local etcd_setting = ALL_SERVICE_SETTING[SCC.Root][SCC.Etcd]
    local instance_setting = ALL_SERVICE_SETTING[SCC.Root][SCC.Services][SCC.Avatar][SCC.Instance][service_id]
    zone_service_mgr = ZoneServiceMgr:new(etcd_setting,
            tonumber(instance_setting[SCC.Id]),
            tonumber(instance_setting[SCC.Listen_Peer_Port]),
            MAIN_ARGS[MAIN_ARGS_SERVICE])
    zone_service_mgr:start()
    on_frame_timeid = native.timer_firm(ServiceMain.on_frame, 1 * 1000, -1)
end

function ServiceMain.OnNotifyQuitGame()
    if on_frame_timeid then
        native.timer_remove(on_frame_timeid)
        on_frame_timeid = nil
    end
    if zone_service_mgr then
        zone_service_mgr:stop()
        zone_service_mgr = nil
    end
end

function ServiceMain.CheckCanQuitGame()
    return true
end

function ServiceMain.on_frame()
    if zone_service_mgr then
        zone_service_mgr:on_frame()
    end
end
