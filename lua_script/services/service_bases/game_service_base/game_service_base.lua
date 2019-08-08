

GameServiceBase = GameServiceBase or class("GameServiceBase", ServiceBase)

function GameServiceBase:ctor()
    GameServiceBase.super.ctor(self)
    self.zone_name = nil
    self.service_name = nil
    self.service_idx = nil
    self.service_identify = nil
    self.zone_net = nil
    self.msg_handler = nil
    self.rpc_mgr = nil
    self.all_service_cfg = nil
    self.service_cfg = nil
    self.etcd_cfg = nil
    self.logic_mgr = nil
    self.hotfix_module = nil
end

function GameServiceBase:init()
    self:idendify_whoami()
    self:init_proto_parser()
    GameServiceBase.super.init(self)

    -- init service logic mgr
    self:setup_logics()
    self.logic_mgr:init()

end

function GameServiceBase:idendify_whoami()
    local SC = Service_Const
    self.zone_name = SERVICE_SETTING[SC.Zone]
    self.service_name = SERVICE_SETTING[SC.Service]
    self.service_idx = SERVICE_SETTING[SC.Idx]
    local all_service_cfg_file = path.combine(MAIN_ARGS[MAIN_ARGS_DATA_DIR], SERVICE_SETTING[SC.All_Service_Config])
    self.all_service_cfg = GameAllServiceConfig.parse_file(all_service_cfg_file)
    self.service_cfg = self.all_service_cfg:get_game_service(self.zone_name, self.service_name, self.service_idx)
    assert(self.service_cfg)
    self.service_identify = self.service_cfg[SC.Service_Id]
end

function GameServiceBase:init_proto_parser()
    local proto_dir = path.combine(MAIN_ARGS[MAIN_ARGS_DATA_DIR], "proto")
    local proto_files  = get_game_proto_files()
    local pid_proto_map = get_game_pid_proto_map()
    PROTO_PARSER = parse_proto({ proto_dir }, proto_files, pid_proto_map)
    assert(PROTO_PARSER, "PROTO_PARSER init fail")
end

function GameServiceBase:setup_modules()
    log_debug("ServiceBase:setup_modules")
    -- zone net module
    local SC = Service_Const
    self.etcd_cfg = self.all_service_cfg:get_third_party_service(SC.Etcd_Service, self.zone_name)
    local zone_net = ZoneNetModule:new(self.module_mgr, "zone_net")
    self.module_mgr:add_module(zone_net)
    zone_net:init(
            self.etcd_cfg[SC.Etcd_Host],
            self.etcd_cfg[SC.Etcd_User],
            self.etcd_cfg[SC.Etcd_Pwd],
            self.etcd_cfg[SC.Etcd_Ttl],
            self.zone_name,
            self.service_name,
            self.service_idx,
            self.service_identify,
            self.service_cfg[SC.Port],
            self.service_cfg[SC.Ip])
    self:_init_zone_net_msg_handler()
    self:_init_zone_net_rpc_mgr()
    self.rpc_mgr:init(self.msg_handler)
    zone_net:add_msg_handler(self.msg_handler)
    -- service logic mgr
    local logic_mgr = ServiceLogicMgr:new(self.module_mgr, "logic_mgr")
    self.module_mgr:add_module(logic_mgr)
    local hotfix_module = HotfixModule:new(self.module_mgr, "hotfix_module")
    self.module_mgr:add_module(hotfix_module)
    local hotifx_dir_path = path.combine(lfs.currentdir(), "hotifx_dir")
    self.hotfix_module:init(hotifx_dir_path)
	lfs.mkdir(hotifx_dir_path)
end

function GameServiceBase:_init_zone_net_msg_handler()
    assert(false, "should not reach here")
end

function GameServiceBase:_init_zone_net_rpc_mgr()
    assert(false, "should not reach here")
end

function GameServiceBase:create_rpc_client(...)
    return create_rpc_client(self.rpc_mgr, ...)
end

function GameServiceBase:setup_logics()
    assert(false, "should not reach here")
end

function GameServiceBase:start()
    GameServiceBase.super.start(self)
end

function GameServiceBase:stop()
    GameServiceBase.super.stop(self)
end

function GameServiceBase:OnNotifyQuitGame()
    GameServiceBase.super.OnNotifyQuitGame(self)
end

function GameServiceBase:CheckCanQuitGame()
    local can_quit = GameServiceBase.super.CheckCanQuitGame(self)
    if not can_quit then
        return false
    end
    return true
end

function GameServiceBase:on_frame()
    GameServiceBase.super.on_frame(self)
    self.rpc_mgr:on_frame()
end

function GameServiceBase:set_process_msg_fn(pid, fn)
    self.msg_handler:set_handler_msg_fn(pid, fn)
end

function GameServiceBase:set_process_rpc_fn(fn_name, fn)
    self.rpc_mgr:set_req_msg_process_fn(fn_name, fn)
end

function GameServiceBase:set_process_rpc_coroutin_fn(fn_name, fn)
    self.rpc_mgr:set_req_msg_coroutine_process_fn(fn_name, fn)
end