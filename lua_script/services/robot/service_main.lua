
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

