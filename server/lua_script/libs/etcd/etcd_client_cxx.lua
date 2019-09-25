
EtcdClientCxx = EtcdClientCxx or {}

function EtcdClientCxx.instance_one(host, user_name, pwd)
    local ret = EtcdClient:new(host)
    return ret
end

function EtcdClientCxx.make_op_cb_fn(cxx_cb_fn)
    if not cxx_cb_fn then
        return nil
    end
    local fn = function (id, op, result)
        local json_str = result:to_json()
        cxx_cb_fn(id, json_str)
        -- log_debug("EtcdClientCxx.make_op_cb_fn %s %s %s", id, string.toprint(op), string.toprint(result))
    end
    return fn
end