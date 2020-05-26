

function RoleMgr:_setup_event_handler__match()
    self.event_proxy:bind(Event.match_agent_disconnect, Functional.make_closure(self._on_event_match_service_disconnect, self))
end

function RoleMgr:_on_event_match_service_disconnect(service_key)
    
end

