
MatchAgentMgr = MatchAgentMgr or class("MatchAgentMgr", ServiceLogic)
MatchAgentMgr.Query_Match_Service_Span_Sec = 5

function MatchAgentMgr:ctor(logic_mgr, logic_name)
    MatchAgentMgr.super.ctor(self, logic_mgr, logic_name)
    self._last_query_match_service_sec = 0
    self._match_service_state_map = {}
    self._timer_proxy = nil
    self._event_proxy = nil
end

function MatchAgentMgr:init()
    MatchAgentMgr.super.init(self)
    self._timer_proxy = TimerProxy:new()
    self._event_proxy = self.service:create_event_proxy()
end

function MatchAgentMgr:start()
    MatchAgentMgr.super.start(self)
    self._timer_proxy:firm(Functional.make_closure(self._on_tick, self), 1 * 1000, -1)
    self._event_proxy:subscribe(Zone_Service_Mgr_Event_Disconnected_Service, Functional.make_closure(self._on_event_service_disconnect, self))
end

function MatchAgentMgr:stop()
    MatchAgentMgr.super.stop(self)
    self._timer_proxy:release_all()
end

function MatchAgentMgr:pick_agent(match_type, role)
    log_debug("MatchAgentMgr:pick_agent %s", self._match_service_state_map)
    local service_key, _ = random.pick_one(self._match_service_state_map)
    return service_key
end

function MatchAgentMgr:_on_tick()
    local now_sec = logic_sec()
    if now_sec >= self._last_query_match_service_sec + MatchAgentMgr.Query_Match_Service_Span_Sec then
        self._last_query_match_service_sec = now_sec
        self:query_match_service_state()
    end
end

function MatchAgentMgr:query_match_service_state(service_key)
    -- log_debug("MatchAgentMgr:query_match_service_state 1")
    local service_key_set = {}
    if service_key then
        service_key_set[service_key] = true
    else
        for _, service_info in pairs(self.service.zone_net:get_service_group(Service_Const.match)) do
            if service_info.net_connected then
                service_key_set[service_info.key] = true
            end
        end
    end
    for sk, _ in pairs(service_key_set) do
        self.service.rpc_mgr:call(Functional.make_closure(self._on_cb_query_match_service_state, self, sk), sk, MatchRpcFn.query_service_state)
    end
end

function MatchAgentMgr:_on_cb_query_match_service_state(service_key, rpc_error, rpc_ret)
    if Error_None ~= rpc_error then
        return
    end
    local service_state = {

    }
    self._match_service_state_map[service_key] = service_state
end

function MatchAgentMgr:_on_event_service_disconnect(service_info)
    if self._match_service_state_map[service_info.key] then
        self._match_service_state_map[service_info.key] = nil
        self._event_proxy:fire(Event.match_agent_disconnect, service_info.key)
    end
end





