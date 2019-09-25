
GateService = GateService or class("GateService", GameServiceBase)

for _, v in ipairs(require("services.gate.service_require_files")) do
    require(v)
end

function create_service_main()
    return GateService:new()
end

function GateService:ctor()
    GateService.super.ctor(self)
    self.client_cnn_mgr = nil
end

function GateService:setup_modules()
    self:_init_client_cnn_mgr()
    GateService.super.setup_modules(self)
end

