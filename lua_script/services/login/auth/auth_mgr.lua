
AuthMgr = AuthMgr or class("AuthMgr", ServiceLogic)

function AuthMgr:ctor(logic_mgr, logic_name)
    AuthMgr.super.ctor(self, logic_mgr, logic_name)
    self.auth_items = {}
    self.client_cnn_mgr = self.service.client_cnn_mgr
end

function AuthMgr:init()
    AuthMgr.super.init(self)
    self.timer_proxy = TimerProxy:new()
    self.event_proxy:subscribe(Login_Game_Event_Stop_Login, Functional.make_closure(self._on_event_stop_login, self))
end

function AuthMgr:start()
    AuthMgr.super.start(self)
    self.timer_proxy:release_all()
    local Tick_Span_Ms = 2 * 1000
    self.timer_proxy:firm(Functional.make_closure(self._on_tick, self), Tick_Span_Ms, -1)
end


function AuthMgr:stop()
    AuthMgr.super.stop(self)
    self.timer_proxy:release_all()
    self.event_proxy:release_all()
    self.auth_items = {}
end

function AuthMgr:_on_event_stop_login(netid)

end

function AuthMgr:_on_tick()

end
