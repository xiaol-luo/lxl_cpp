
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
    -- self.service_id = nil

    self.avatar_rpc_client = nil
end

function AvatarService.fill_service_infos() end

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

    local SC = Service_Const
    local etcd_cfg_file = path.combine(MAIN_ARGS[MAIN_ARGS_DATA_DIR], SERVICE_SETTING[SC.Etcd_Cfg_File])
    local etcd_cfg = xml.parse_file(etcd_cfg_file)
    xml.print_table(etcd_cfg)
    etcd_cfg = etcd_cfg[SC.Root]
    local etcd_svr_cfg = etcd_cfg[self.zone_name][SC.Etcd]
    local etcd_service_cfg = etcd_cfg[self.zone_name][self.service_name][tostring(self.service_idx)]
    self.service_id = etcd_service_cfg[SC.Id]

    log_debug("1 %s", etcd_svr_cfg)
    log_debug("2 %s", etcd_service_cfg)
    log_debug("3 %s %s %s",  self.zone_name, self.service_name, self.service_idx)

    local zone_net_module = ZoneNetModule:new(self.module_mgr, "zone_net")
    self.module_mgr:add_module(zone_net_module)
    zone_net_module:init(
            etcd_svr_cfg[SC.Etcd_Host], etcd_svr_cfg[SC.Etcd_User], etcd_svr_cfg[SC.Etcd_Pwd], etcd_svr_cfg[SC.Etcd_Ttl],
            self.zone_name, self.service_name, self.service_idx,
            etcd_service_cfg[SC.Id], etcd_service_cfg[SC.Listen_Port], etcd_service_cfg[SC.Listen_Ip])
end

function AvatarService:create_zone_service_msg_handler()
    local msg_handler = AvatarZoneServiceMsgHandler:new()
    msg_handler:init()
    return msg_handler
end

function AvatarService:start()
    AvatarService.super.start(self)
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
end

