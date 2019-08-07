
RobotService = RobotService or class("RobotService", GameServiceBase)

for _, v in ipairs(require("services.robot.service_require_files")) do
    require(v)
end

function create_service_main()
    return RobotService:new()
end

function RobotService:ctor()
    RobotService.super.ctor(self)
end

function RobotService:setup_modules()
    RobotService.super.setup_modules(self)
end


function RobotService:setup_modules()
    log_debug("ServiceBase:setup_modules")
    -- zone net module
    local SC = Service_Const
    self.etcd_cfg = self.all_service_cfg:get_third_party_service(SC.Etcd_Service, self.zone_name)

    self:_init_zone_net_msg_handler()
    self:_init_zone_net_rpc_mgr()

    -- service logic mgr
    local logic_mgr = ServiceLogicMgr:new(self.module_mgr, "logic_mgr")
    self.module_mgr:add_module(logic_mgr)
    local hotfix_module = HotfixModule:new(self.module_mgr, "hotfix_module")
    self.module_mgr:add_module(hotfix_module)
    local hotifx_dir_path = path.combine(lfs.currentdir(), "hotifx_dir")
    self.hotfix_module:init(hotifx_dir_path)
    lfs.mkdir(hotifx_dir_path)
end

