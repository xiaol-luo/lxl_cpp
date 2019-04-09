
ServiceMain = ServiceMain or {}
ServiceMain.zs_mgr = nil
ServiceMain.zs_msg_handler = nil

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
    ServiceMain.zs_mgr = ZoneServiceMgr:new(etcd_setting,
            tonumber(instance_setting[SCC.Id]),
            tonumber(instance_setting[SCC.Listen_Peer_Port]),
            MAIN_ARGS[MAIN_ARGS_SERVICE])
    ServiceMain.zs_msg_handler = AvatarZoneServiceMsgHandler:new()
    ServiceMain.zs_msg_handler:init()
    ServiceMain.zs_mgr:add_msg_handler(ServiceMain.zs_msg_handler)
    ServiceMain.zs_mgr:start()
    on_frame_timeid = native.timer_firm(ServiceMain.on_frame, 1 * 1000, -1)
end

function ServiceMain.OnNotifyQuitGame()
    if on_frame_timeid then
        native.timer_remove(on_frame_timeid)
        on_frame_timeid = nil
    end
    if ServiceMain.zs_mgr then
        ServiceMain.zs_mgr:stop()
        ServiceMain.zs_mgr = nil
    end
end

function ServiceMain.CheckCanQuitGame()
    return true
end

function ServiceMain.on_frame()
    if ServiceMain.zs_mgr then
        ServiceMain.zs_msg_handler:send(ServiceMain.zs_mgr.etcd_service_key, 5, {})
        ServiceMain.zs_mgr:on_frame()
    end

    local test_tb = {
        id=1235784,
        name="xxx",
    }
    -- log_debug("encode 1 xxxxxxxxxxx %s", PROTO_PARSER:encode(1, test_tb))
    -- log_debug("decode 1 yyyyyyyyyyy %s", PROTO_PARSER:decode(1, PROTO_PARSER:encode(1, test_tb)))
end
