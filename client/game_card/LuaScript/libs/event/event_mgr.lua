
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
    local ev_map = self.event_map[node.name]
    if ev_map then
        ev_map[node.id] = nil
    end
end

---@return EventProxySet
function EventMgr:create_proxy()
    local ret = EventProxy:new(self)
    return ret
end


