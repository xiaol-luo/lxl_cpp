Client_Cnn_Tolerate_No_Recv_Sec = 15

ClientCnnMgr = ClientCnnMgr or class("ClientCnnMgr", ServiceListenModule)

function ClientCnnMgr:ctor(module_mgr, module_name)
    ClientCnnMgr.super.ctor(self, module_mgr, module_name)
end

function ClientCnnMgr:init(listen_port)
    ClientCnnMgr.super.init(self, listen_port)
end


function ClientCnnMgr:start()
end

function ClientCnnMgr:stop()
    ClientCnnMgr.super.stop(self)
end