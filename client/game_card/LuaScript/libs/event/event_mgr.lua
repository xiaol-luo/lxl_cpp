
---@class EventMgr
EventMgr = EventMgr or class("EventMgr")

function EventMgr:ctor()
    self.seq_id = 0
    self.event_map = {} -- { ev_name={ id=?, ev_name=?, fn=?} }
    self.id_to_node = {}
end

function EventMgr:next_seq_id()
    self.seq_id = self.seq_id + 1
    return self.seq_id
end

function EventMgr:bind(ev_name, fn)
    assert(ev_name)
    assert(is_function(fn))
    local node = {}
    node.id = self:next_seq_id()
    node.name = ev_name
    node.fn = fn
    local ev_map = self.event_map[ev_name]
    if not ev_map then
        ev_map = {}
        self.event_map[ev_name] = ev_map
    end
    ev_map[node.id] = node
    self.id_to_node[node.id] = node
    return node.id
end

function EventMgr:fire(ev_name, ...)
    local ev_map = self.event_map[ev_name]
    if ev_map then
        for _, node in pairs(ev_map) do
            node.fn(...)
        end
    end
end

function EventMgr:cancel(id)
    local node = self.id_to_node[id]
    self.id_to_node[id] = nil
    if node then
        local ev_map = self.event_map[node.name]
        if ev_map then
            ev_map[node.id] = nil
        end
    end
end

function EventMgr:cancel_all()
    self.id_to_node = {}
    self.event_map = {}
end

---@return EventProxy
function EventMgr:create_proxy()
    local ret = EventProxy:new(self)
    return ret
end

function declare_event_set(event_set_name, event_set_tb)
    assert(is_string(event_set_name))
    assert(is_table(event_set_tb))

    local event_set = _G[event_set_name]
    if not event_set then
        event_set = {}
        _G[event_set_name] = event_set
    end
    for _, v in pairs(event_set_tb) do
        if not event_set[k] then
            local event_value = string.format("%s.%s", event_set_name, v)
            event_set[v] = event_value
        end
    end
    return event_set
end

