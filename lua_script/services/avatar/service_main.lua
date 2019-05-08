
for _, v in ipairs(require("services.avatar.avatar_service_files")) do
    require(v)
end

function create_service_main()
    return AvatarService:new()
end

AvatarService = AvatarService or class("AvatarService", ServiceBase)

function AvatarService:ctor()
    AvatarService.super.ctor(self)
    self.zone_name = nil
    self.service_name = nil
    self.service_idx = nil
    self.zone_net = nil
    self.msg_handler = nil
    self.rpc_mgr = nil
    self.http_net = nil
end

function AvatarService:init()
    -- init global PROTO_PARSER
    local proto_dir = path.combine(MAIN_ARGS[MAIN_ARGS_DATA_DIR], "proto")
    local proto_files = {} -- Todo: set this table by config
    local pid_proto_map = {} -- Todo: set this table by config
    PROTO_PARSER = parse_proto({ proto_dir }, proto_files, pid_proto_map)
    assert(PROTO_PARSER, "PROTO_PARSER init fail")

    self.zone_name = SERVICE_SETTING[Service_Const.Zone]
    self.service_name = SERVICE_SETTING[Service_Const.Service]
    self.service_idx = SERVICE_SETTING[Service_Const.Idx]

    AvatarService.super.init(self)
end

function ServiceBase:setup_modules()
    log_debug("ServiceBase:setup_modules")

    -- zone net module
    local SC = Service_Const
    local etcd_cfg_file = path.combine(MAIN_ARGS[MAIN_ARGS_DATA_DIR], SERVICE_SETTING[SC.Etcd_Cfg_File])
    local etcd_cfg = xml.parse_file(etcd_cfg_file)
    xml.print_table(etcd_cfg)
    etcd_cfg = etcd_cfg[SC.Root]
    local etcd_svr_cfg = etcd_cfg[self.zone_name][SC.Etcd]
    local etcd_service_cfg = etcd_cfg[self.zone_name][self.service_name][tostring(self.service_idx)]
    self.service_id = etcd_service_cfg[SC.Id]
    self.zone_net = ZoneNetModule:new(self.module_mgr, "zone_net")
    self.module_mgr:add_module(self.zone_net)
    self.zone_net:init(
            etcd_svr_cfg[SC.Etcd_Host], etcd_svr_cfg[SC.Etcd_User], etcd_svr_cfg[SC.Etcd_Pwd], etcd_svr_cfg[SC.Etcd_Ttl],
            self.zone_name, self.service_name, self.service_idx,
            etcd_service_cfg[SC.Id], etcd_service_cfg[SC.Listen_Port], etcd_service_cfg[SC.Listen_Ip])
    self.msg_handler = self:new_zone_net_msg_handler()
    self.rpc_mgr = self:new_zone_net_rpc_mgr()
    self.rpc_mgr:init(self.msg_handler)
    self.zone_net:add_msg_handler(self.msg_handler)

    -- http net module
    local http_handle_fns = {}
    self.http_net = HttpNetModule:new(self.module_mgr, "http_net")
    self.http_net:init(1080, http_handle_fns)
    self.module_mgr:add_module(self.http_net)
end

function AvatarService:new_zone_net_msg_handler()
    local msg_handler = AvatarZoneServiceMsgHandler:new()
    msg_handler:init()
    return msg_handler
end

function AvatarService:new_zone_net_rpc_mgr()
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
    AvatarService.super.start(self)
    self.avatar_rpc_client = create_rpc_client(self.rpc_mgr, self.zone_name, self.service_name, self.service_idx)
    self:for_test()
end

function AvatarService:stop()
    AvatarService.super.stop(self)
end

function AvatarService:OnNotifyQuitGame()
    AvatarService.super.OnNotifyQuitGame(self)
end

function AvatarService:CheckCanQuitGame()
    local can_quit = AvatarService.super.CheckCanQuitGame(self)
    if not can_quit then
        return false
    end
    return true
end

function AvatarService:on_frame()
    AvatarService.super.on_frame(self)
    self.rpc_mgr:on_frame()
end

function AvatarService:for_test()
    g_co = coroutine.create(function ()
        log_debug("reach here 1")
        local v1, v2, v3 = self.avatar_rpc_client:hello_world(1, "aaa")
        log_debug("xxxxxxxxxxxx %s %s %s", v1, v2, v3)

        v1, v2, v3 = self.avatar_rpc_client:hello_world(2, "bbb")
        log_debug("xxxxxxxxxxxx 2 %s %s %s", v1, v2, v3)

        v1, v2, v3 = self.avatar_rpc_client:simple_rsp(2, "bbb")
        log_debug("xxxxxxxxxxxx 3 %s %s %s", v1, v2, v3)

    end)

    timer_delay(function()
        local st, msg = coroutine_resume(g_co)
        if not st then
            log_debug("coroutine_resume(g_co) error:%s", msg)
        end
    end, 2000)
end
