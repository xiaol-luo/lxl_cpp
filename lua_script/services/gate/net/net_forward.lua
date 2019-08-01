
NetForward = NetForward or class("NetForward", ServiceLogic)

function NetForward:ctor(logic_mgr, logic_name)
    NetForward.super.ctor(self, logic_mgr, logic_name)
    self.client_cnn_mgr = self.service.client_cnn_mgr
end

function NetForward:init()
    NetForward.super.init(self)
    self.client_cnn_mgr:set_process_fn(ProtoId.req_client_forward_game, Functional.make_closure(self._on_client_forward_game, self))
end

function NetForward:_on_client_forward_game(netid, pid, msg)
    local client = self.service.client_mgr:get_client(netid)
    if not client or ClientState.In_Game ~= client.state then
        return
    end
    if not client.game_client or not client.launch_role_id then
        return
    end
    client.game_client:call(nil, GameRpcFn.client_forward_msg, client.launch_role_id, msg.proto_id, msg.proto_bytes)
end
