
LoginGameMgr = LoginGameMgr or class("LoginGameMgr", ServiceLogic)

function LoginGameMgr:ctor(logic_mgr, logic_name)
    LoginGameMgr.super.ctor(self, logic_mgr, logic_name)
    self.login_items = {}
    self.client_cnn_mgr = self.service.client_cnn_mgr
end

function LoginGameMgr:init()
    LoginGameMgr.super.init(self)
    self.timer_proxy = TimerProxy:new()
    self.client_cnn_mgr:set_process_fn(ProtoId.req_login_game, Functional.make_closure(self.process_req_login_game, self))
end

function LoginGameMgr:start()
    LoginGameMgr.super.start(self)
    self.timer_proxy:release_all()
    local Tick_Span_Ms = 2 * 1000
    self.timer_proxy:firm(Functional.make_closure(self._on_tick, self), Tick_Span_Ms, -1)
    self.event_proxy:subscribe(Client_Cnn_Event_New_Client, Functional.make_closure(self._on_new_cnn, self))
    self.event_proxy:subscribe(Client_Cnn_Event_Close_Client, Functional.make_closure(self._on_close_cnn, self))
end


function LoginGameMgr:stop()
    LoginGameMgr.super.stop(self)
    self.timer_proxy:release_all()
    self.event_proxy:release_all()
end

function LoginGameMgr:_on_new_cnn(netid, error_code)
    log_debug("LoginGameMgr._on_new_cnn")
    if 0 ~= error_code then
        return
    end
    local item = LoginGameItem:new()
    item.netid = netid
    self.login_items[item.netid] = item
end

function LoginGameMgr:_on_close_cnn(netid, error_code)
    self.event_proxy:fire(Login_Game_Event_Stop_Login, netid)
    self.login_items[netid] = nil
end

function LoginGameMgr:_on_tick()

end

function LoginGameMgr:process_req_login_game(netid, pid, msg)
    log_debug("LoginGameMgr.process_req_login_game %s %s", pid, msg)
    self.client_cnn_mgr:send(netid, ProtoId.rsp_login_game, {
        error_code=0, auth_sn="", timestamp=logic_sec()
    })
end