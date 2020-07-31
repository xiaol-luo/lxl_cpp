

---@class EventBinder
EventBinder = EventBinder or class("EventBinder")

function EventBinder:ctor()
    self._gen_id = make_sequence(0)
    self._id_to_bind_datas = {}
    self._mgr_to_proxy = table.gen_weak_table("k")
end

---@param event_mgr EventMgr
---@param ev_name string
function EventBinder:bind(event_mgr, ev_name, fn)
    local ret = nil
    if event_mgr and is_string(ev_name) and is_function(fn) then
        ---@type EventProxy
        local proxy = self._mgr_to_proxy[event_mgr]
        if not proxy then
            proxy = event_mgr:create_proxy()
            self._mgr_to_proxy[event_mgr] = proxy
        end
        local bind_id = proxy:bind(ev_name, fn)
        if bind_id then
            ret = self._gen_id()
            self._id_to_bind_datas[ret] = {
                proxy = proxy,
                bind_id = bind_id,
            }
        end
    end
    return ret
end

function EventBinder:cancel(id)
    local bind_data = self._id_to_bind_datas[id]
    if bind_data then
        bind_data.proxy:cancel(bind_data.bind_id)
        self._id_to_bind_datas[id] = nil
    end
end

function EventBinder:release_all()
    for _, bind_data in pairs( self._id_to_bind_datas) do
        bind_data.proxy:cancel(bind_data.bind_id)
    end
    self._id_to_bind_datas = {}
end

function EventBinder:batch_bind(event_mgr, ev_name_fns)
    local ret = {}
    if event_mgr and is_table(ev_name_fns) then
        for ev_name, fn in pairs(ev_name_fns) do
            local id = self:bind(event_mgr, ev_name, fn)
            if id then
                table.insert(ret, id)
            end
        end
    end
    return ret
end

function EventBinder:batch_cancel(ids)
    if ids then
        for _, id in pairs(ids) do
            self:cancel(id)
        end
    end
end
