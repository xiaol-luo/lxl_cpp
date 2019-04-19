
for _, v in ipairs(require("services.avatar.avatar_service_files")) do
    require(v)
end

function create_service_main()
    return AvatarService:new()
end

AvatarService = AvatarService or class("AvatarService", ServiceBase)

function AvatarService:ctor()
    self.super.ctor(self)
    self.avatar_rpc_client = nil
end

function AvatarService:init()
    self.super.init(self)
end

function AvatarService:create_zone_service_msg_handler()
    local msg_handler = AvatarZoneServiceMsgHandler:new()
    msg_handler:init()
    return msg_handler
end

function AvatarService:create_zone_service_rpc_mgr()
    local rpc_mgr = ZoneServiceRpcMgr:new()

    local co_fn = function(rsp, ...)
        log_debug("aaaaaaaaaaaaaaaaaaaaaaaaaaa 2")
        local st, p1, p2 = self.avatar_rpc_client:simple_rsp("p1", "p2")
        log_debug("in process fn hello world 1 %s %s %s", st, p1, p2)
        rsp:add_delay_execute(function ()
            self.avatar_rpc_client:call(nil, "simple_rsp", 1, 2, 3)
            log_debug("reach delay execute fn")
        end)
        st, p1, p2 = self.avatar_rpc_client:simple_rsp("p3", "p4")
        log_debug("in process fn hello world 2 %s %s %s", st, p1, p2)
        -- rsp:respone(...)
        return Rpc_Const.Action_Return_Result, ...
    end
    rpc_mgr:set_req_msg_coroutine_process_fn("hello_world", co_fn)

    local simple_rsp_fn = function(rsp, ...)
        rsp:respone(...)
    end
    rpc_mgr:set_req_msg_process_fn("simple_rsp", simple_rsp_fn)

    return rpc_mgr
end

function AvatarService:start()
    self.super.start(self)

    self.avatar_rpc_client = RpcClient:new(self.zone_service_rpc_mgr, self.zone_service_mgr.etcd_service_key)
    self:for_test()
end

function AvatarService:stop()
    self.super.stop(self)
end

function AvatarService:OnNotifyQuitGame()
    self.super.OnNotifyQuitGame(self)
end

function AvatarService:CheckCanQuitGame()
    local can_quit = self.super.CheckCanQuitGame(self)
    if not can_quit then
        return false
    end
    return true
end

function AvatarService:on_frame()
    self.super.on_frame(self)
end

function AvatarService:for_test()
    self.avatar_rpc_client:setup_coroutine_fns({"hello_world", "simple_rsp"})
    g_co = coroutine.create(function ()
        log_debug("reach here 1")
        local v1, v2, v3 = self.avatar_rpc_client:hello_world(1, "aaa")
        log_debug("xxxxxxxxxxxx %s %s %s", v1, v2, v3)

        v1, v2, v3 = self.avatar_rpc_client:hello_world(2, "bbb")
        log_debug("xxxxxxxxxxxx 2 %s %s %s", v1, v2, v3)
    end)

    native.timer_firm(function()
        local st, msg = coroutine_resume(g_co)
        if not st then
            log_debug("coroutine_resume(g_co) error:%s", msg)
        end
    end, 2000, 1)
end
