
NetForward = NetForward or class("NetForward", ServiceLogic)

function NetForward:ctor(logic_mgr, logic_name)
    NetForward.super.ctor(self, logic_mgr, logic_name)
    self.client_cnn_mgr = self.service.client_cnn_mgr
end

function NetForward:init()
    NetForward.super.init(self)
    self.client_cnn_mgr:set_process_fn(ProtoId.req_user_login, Functional.make_closure(self.process_req_user_login, self))
end
