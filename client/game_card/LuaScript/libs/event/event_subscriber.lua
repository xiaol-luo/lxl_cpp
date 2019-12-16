

EventSubscriber = EventSubscriber or class("EventSubscriber")

function EventSubscriber:ctor(event_mgr)
    assert(event_mgr)
    self.wt = {}
    setmetatable(self.wt, {mode='v'})

    self.wt.event_mgr = event_mgr
    self.subscribe_ids = {}
end

function EventSubscriber:subscribe(ev_name, fn)
    if not self.wt.event_mgr then
        return 0
    end
    local id = self.wt.event_mgr:subscribe(ev_name, fn)
    if id > 0 then
        self.subscribe_ids[id] = true
    end
end

function EventSubscriber:cancel(id)
    if self.subscribe_ids[id] then
        self.subscribe_ids[id] = nil
        if self.wt.event_mgr then
            self.wt.event_mgr:cancel(id)
        end
    end
end

function EventSubscriber:release_all()
    local ids = self.subscribe_ids
    self.subscribe_ids = {}
    if self.wt.event_mgr then
        for id, _ in pairs(ids) do
            self.wt.event_mgr:cancel(id)
        end
    end
end

