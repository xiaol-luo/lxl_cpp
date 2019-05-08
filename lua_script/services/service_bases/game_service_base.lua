

GameServiceBase = GameServiceBase or class("GameServiceBase", ServiceBase)

function GameServiceBase:ctor()
    GameServiceBase.super.ctor(self)
    self.zone_name = nil
    self.service_name = nil
    self.service_idx = nil
    self.zone_net = nil
    self.msg_handler = nil
    self.rpc_mgr = nil
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
end

function GameServiceBase:idendify_whoami()
    self.zone_name = SERVICE_SETTING[Service_Const.Zone]
    self.service_name = SERVICE_SETTING[Service_Const.Service]
    self.service_idx = SERVICE_SETTING[Service_Const.Idx]
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