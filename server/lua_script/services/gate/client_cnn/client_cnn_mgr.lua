
ClientCnnMgr = ClientCnnMgr or class("ClientCnnMgr", ClientCnnMgrBase)

function ClientCnnMgr:init(listen_port, cnn_tolerate_no_recv_sec, client_cnn_cls)
    ClientCnnMgr.super.init(self, listen_port, cnn_tolerate_no_recv_sec, client_cnn_cls)

    self.client_connect_ip = self.service.service_cfg[Service_Const.Client_Ip]
    assert(self.client_connect_ip and #self.client_connect_ip > 0)
end

function ClientCnnMgr:start()
    ClientCnnMgr.super.start(self)
    self.service.rpc_mgr:set_req_msg_process_fn(GateRpcFn.query_state, Functional.make_closure(self.on_rpc_query_state, self))
    self.service.rpc_mgr:set_req_msg_process_fn(GateRpcFn.kick_client, Functional.make_closure(self.on_kick_client, self))
end

function ClientCnnMgr:on_rpc_query_state(rpc_rsp)
    local ret = {
        client_connect_ip = self.client_connect_ip,
        client_connect_port = self.listen_port,
    }
    rpc_rsp:response(ret)
end

function ClientCnnMgr:on_kick_client(rpc_rsp, netid, kick_reason)
    rpc_rsp:response()
    Net.close(netid)
end