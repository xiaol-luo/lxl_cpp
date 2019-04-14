
ServiceMain = ServiceMain or {}
ServiceMain.zs_mgr = nil
ServiceMain.zs_msg_handler = nil
ServiceMain.zs_rpc = nil
ServiceMain.avatar_rpc_client = nil
local on_frame_timeid = nil

g_co = coroutine.create(function ()
    log_debug("reach here 1")
    local v1, v2, v3 = ServiceMain.avatar_rpc_client:hello_world(1, "aaa")
    log_debug("xxxxxxxxxxxx %s %s %s", v1, v2, v3)

    v1, v2, v3 = ServiceMain.avatar_rpc_client:hello_world(1, "aaa")
    log_debug("xxxxxxxxxxxx2 %s %s %s", v1, v2, v3)
end)

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
    ServiceMain.zs_rpc = ZoneServiceRpcMgr:new()
    ServiceMain.zs_rpc:init(ServiceMain.zs_msg_handler)
    ServiceMain.avatar_rpc_client = RpcClient:new(ServiceMain.zs_rpc, ServiceMain.zs_mgr.etcd_service_key)
    ServiceMain.avatar_rpc_client:setup_corotine_fns({"hello_world", "simple_rsp"})
    on_frame_timeid = native.timer_firm(ServiceMain.on_frame, 1 * 1000, -1)

    native.timer_firm(function()
        local st, msg = coroutine_resume(g_co)
        if not st then
            log_debug("coroutine_resume(g_co) error:%s", msg)
        end
    end, 2000, 1)
end

function ServiceMain.OnNotifyQuitGame()
    if on_frame_timeid then
        native.timer_remove(on_frame_timeid)
        on_frame_timeid = nil
    end
    if ServiceMain.zs_rpc then
        ServiceMain.zs_rpc:destroy()
        ServiceMain.zs_rpc = nil
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
        -- ServiceMain.zs_msg_handler:send(ServiceMain.zs_mgr.etcd_service_key, 5, {})
        -- ServiceMain.zs_msg_handler:send(ServiceMain.zs_mgr.etcd_service_key, System_Pid.Zone_Service_Rpc_Req, {})
        ServiceMain.zs_mgr:on_frame()
    end
    if ServiceMain.zs_rpc then
        local fn = function(rpc_err, ...)
            log_debug("ServiceMain.zs_rpc:call callback reach rpc_err:%s, params:%s", rpc_err, {...})
        end
        -- ServiceMain.zs_rpc:call(fn, ServiceMain.zs_mgr.etcd_service_key, "hello_world", 1, 2, "xxx")
        -- ServiceMain.zs_rpc:call(fn, ServiceMain.zs_mgr.etcd_service_key, "hello_world", nil, nil, "xxx", nil, 1, nil)
        ServiceMain.zs_rpc:on_frame()
    end
end
