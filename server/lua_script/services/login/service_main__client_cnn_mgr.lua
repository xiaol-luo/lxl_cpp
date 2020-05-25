
ClientCnnMgr = ClientCnnMgr or class("ClientCnnMgr", ClientCnnMgrBase)

function LoginService:_init_client_cnn_mgr()
    self.module_mgr:add_module(ClientCnnMgr:new(self.module_mgr, "client_cnn_mgr"))

    local listen_port = self.service_cfg[Service_Const.Client_Port]
    self.client_cnn_mgr:init(listen_port, 20)
end