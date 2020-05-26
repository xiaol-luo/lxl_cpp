
---@class EventProxy
EventProxy = EventProxy or class("EventProxy")

function EventProxy:ctor(event_mgr)
    assert(event_mgr)
    self._wt = {}
    setmetatable(self._wt, {__mode = "v"})
    self._wt.event_mgr = event_mgr
    self.bind_ids = {}
end

function EventProxy:bind(ev_name, fn)
    local id = nil
    if self._wt.event_mgr then
        id = self._wt.event_mgr:bind(ev_name, fn)
        if id then
            self.bind_ids[id] = true
        end
    end
    return id
end

function EventProxy:cancel(id)
    if self.bind_ids[id] then
        self.bind_ids[id] = nil
        if self._wt.event_mgr then
            self._wt.event_mgr:cancel(id)
        end
    end
end

function EventProxy:release_all()
    local ids = self.bind_ids
    self.bind_ids = {}
    if self._wt.event_mgr then
        for id, _ in pairs(ids) do
            self.event_mgr:cancel(id)
        end
    end
end
