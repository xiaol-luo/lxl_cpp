
ServiceMain = ServiceMain or {}
ServiceMain.zs_mgr = nil
ServiceMain.zs_msg_handler = nil
ServiceMain.zs_rpc = nil
ServiceMain.avatar_rpc_client = nil
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
    ServiceMain.zs_rpc = ZoneServiceRpcMgr:new()
    ServiceMain.zs_rpc:init(ServiceMain.zs_msg_handler)
    ServiceMain.avatar_rpc_client = RpcClient:new(ServiceMain.zs_rpc, ServiceMain.zs_mgr.etcd_service_key)
    on_frame_timeid = native.timer_firm(ServiceMain.on_frame, 1 * 1000, -1)

    for_test()
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
        --[[
        ServiceMain.zs_msg_handler:send(ServiceMain.zs_mgr.etcd_service_key, 5, {})
        ServiceMain.zs_msg_handler:send(ServiceMain.zs_mgr.etcd_service_key, System_Pid.Zone_Service_Rpc_Req, {})
        ]]
        ServiceMain.zs_mgr:on_frame()
    end
    if ServiceMain.zs_rpc then
        --[[
        local fn = function(rpc_err, ...)
            log_debug("ServiceMain.zs_rpc:call callback reach rpc_err:%s, params:%s", rpc_err, {...})
        end
        ServiceMain.zs_rpc:call(fn, ServiceMain.zs_mgr.etcd_service_key, "hello_world", 1, 2, "xxx")
        ServiceMain.zs_rpc:call(fn, ServiceMain.zs_mgr.etcd_service_key, "hello_world", nil, nil, "xxx", nil, 1, nil)
        ]]
        ServiceMain.zs_rpc:on_frame()
    end
end

function for_test()
    ServiceMain.avatar_rpc_client:setup_coroutine_fns({"hello_world", "simple_rsp"})
    g_co = coroutine.create(function ()
        log_debug("reach here 1")
        local v1, v2, v3 = ServiceMain.avatar_rpc_client:hello_world(1, "aaa")
        log_debug("xxxxxxxxxxxx %s %s %s", v1, v2, v3)

        v1, v2, v3 = ServiceMain.avatar_rpc_client:hello_world(2, "bbb")
        log_debug("xxxxxxxxxxxx 2 %s %s %s", v1, v2, v3)
    end)

    local co_fn = function(rsp, ...)
        log_debug("aaaaaaaaaaaaaaaaaaaaaaaaaaa 2")
        local st, p1, p2 = ServiceMain.avatar_rpc_client:simple_rsp("p1", "p2")
        log_debug("in process fn hello world 1 %s %s %s", st, p1, p2)
        rsp:add_delay_execute(function ()
            ServiceMain.avatar_rpc_client:call(nil, "simple_rsp", 1, 2, 3)
        end)
        st, p1, p2 = ServiceMain.avatar_rpc_client:simple_rsp("p3", "p4")
        log_debug("in process fn hello world 2 %s %s %s", st, p1, p2)
        -- rsp:respone(...)
        return Rpc_Const.Action_Return_Result, ...
    end
    ServiceMain.zs_rpc:set_req_msg_coroutine_process_fn("hello_world", co_fn)

    local simple_rsp_fn = function(rsp, ...)
        rsp:respone(...)
    end
    ServiceMain.zs_rpc:set_req_msg_process_fn("simple_rsp", simple_rsp_fn)

    native.timer_firm(function()
        local st, msg = coroutine_resume(g_co)
        if not st then
            log_debug("coroutine_resume(g_co) error:%s", msg)
        end
    end, 2000, 1)
end
