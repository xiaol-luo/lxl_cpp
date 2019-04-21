
EventProxy = EventProxy or class("EventProxy")

function EventProxy:ctor(event_mgr)
    assert(event_mgr)
    self.event_mgr = event_mgr
    self.subscribe_ids = {}
end

function EventProxy:subscribe(ev_name, fn)
    local id = self.event_mgr:subscribe(ev_name, fn)
    if id > 0 then
        self.subscribe_ids[id] = true
    end
end

function EventProxy:fire(ev_name, ...)
    self.event_mgr:fire(ev_name, ...)
end

function EventProxy:cancel(id)
    if self.subscribe_ids[id] then
        self.subscribe_ids[id] = nil
        self.event_mgr:cancel(id)
    end
end

function EventProxy:release_all()
    local ids = self.subscribe_ids
    self.subscribe_ids = {}
    for id, _ in pairs(ids) do
        self.event_mgr:cancel(id)
    end
end
