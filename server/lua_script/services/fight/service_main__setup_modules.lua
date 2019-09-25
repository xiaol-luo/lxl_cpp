

function FightService:_init_client_cnn_mgr()
    local client_cnn_mgr = ClientCnnMgr:new(self.module_mgr, "client_cnn_mgr")
    self.module_mgr:add_module(client_cnn_mgr)

    local listen_port = self.service_cfg[Service_Const.Client_Port]
    self.client_cnn_mgr:init(listen_port)
end

function FightService:setup_modules()
    FightService.super.setup_modules(self)
    self:_init_client_cnn_mgr()
end