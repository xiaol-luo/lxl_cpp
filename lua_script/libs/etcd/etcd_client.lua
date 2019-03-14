
EtcdClient = EtcdClient or class("EtcdClient")

function EtcdClient:ctor(host)
    self.host = string.rtrim(host, "/")
end

function EtcdClient:get_host()
    return self.host
end

function EtcdClient:example_cb(id, op, result)

end

function EtcdClient:set(key, value, ttl, cb_fn)
    local op = EtcdClientOpSet:new()
    op[EtcdConst.Key] = key
    op[EtcdConst.Value] = value
    op[EtcdConst.Ttl] = ttl
    op.cb_fn = cb_fn
    self:execute(op)
end

function EtcdClient:get(key, cb_fn)
    local op = EtcdClientOpGet:new()
    op[EtcdConst.Key] = key
    op.cb_fn = cb_fn
    self:execute(op)
end

function EtcdClient:delete(key, cb_fn)
    local op = EtcdClientOpDelete:new()
    op[EtcdConst.Key] = key
    op.cb_fn = cb_fn
    self:execute(op)
end

function EtcdClient:watch(key, waitIndex, recursive, cb_fn)
    local op = EtcdClientOpGet:new()
    op[EtcdConst.Key] = key
    op[EtcdConst.Wait] = true
    op[EtcdConst.WaitIndex] = waitIndex
    op[EtcdConst.Recursive] = recursive
    op.cb_fn = cb_fn
    self:execute(op)
end

function EtcdClient:execute(op)
    return op:execute(self)
end

function EtcdClient._Handle_event_cb(op, op_id, err_type_enum, err_num_int)
    log_debug("EtcdClient._Handle_event_cb %s", op_id)
end

function EtcdClient._handle_set_result_cb(op, op_id, url_str, heads_map, body_str, body_len)
    log_debug("EtcdClient._handle_set_result_cb %s", op_id)
end

function EtcdClient._handle_get_result_cb(op, op_id, url_str, heads_map, body_str, body_len)
    log_debug("EtcdClient._handle_get_result_cb %s", op_id)
end

function EtcdClient._handle_delete_result_cb(op, op_id, url_str, heads_map, body_str, body_len)
    log_debug("EtcdClient._handle_delete_result_cb %s", op_id)
end