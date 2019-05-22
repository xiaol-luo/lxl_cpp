

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
end

function GameServiceBase:init()
    self:idendify_whoami()
    self:init_proto_parser()
    GameServiceBase.super.init(self)
end

function GameServiceBase:setup_modules()
    log_debug("ServiceBase:setup_modules")

    -- zone net module
    local SC = Service_Const
    self.etcd_cfg = self.all_service_cfg:get_third_party_service(SC.Etcd_Service, self.zone_name)
    self.zone_net = ZoneNetModule:new(self.module_mgr, "zone_net")
    self.module_mgr:add_module(self.zone_net)
    self.zone_net:init(
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
    self.msg_handler = self:new_zone_net_msg_handler()
    self.rpc_mgr = self:new_zone_net_rpc_mgr()
    self.rpc_mgr:init(self.msg_handler)
    self.zone_net:add_msg_handler(self.msg_handler)
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
    self.service_identify = self.service_cfg[SC.Id]
end

function GameServiceBase:init_proto_parser()
    local proto_dir = path.combine(MAIN_ARGS[MAIN_ARGS_DATA_DIR], "proto")
    local proto_files = {} -- Todo: set this table by config
    local pid_proto_map = {} -- Todo: set this table by config
    PROTO_PARSER = parse_proto({ proto_dir }, proto_files, pid_proto_map)
    assert(PROTO_PARSER, "PROTO_PARSER init fail")
end

function GameServiceBase:new_zone_net_msg_handler()
    assert("should not reach here")
end

function GameServiceBase:new_zone_net_rpc_mgr()
    assert("should not reach here")
end

function GameServiceBase:start()
    GameServiceBase.super.start(self)
    self.avatar_rpc_client = create_rpc_client(self.rpc_mgr, self.zone_name, self.service_name, self.service_idx)
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