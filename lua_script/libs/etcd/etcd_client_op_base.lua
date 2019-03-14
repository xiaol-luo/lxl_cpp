
EtcdClientOpBase = EtcdClientOpBase or class("EtcdClientOpBase")

function EtcdClientOpBase:ctor()
    self.host_format = "%s/v2/keys%s"
    self.http_heads = {}
    self.http_heads["Content-Type"] = "application/x-www-form-urlencoded"
    self.cb_fn = nil
end

function EtcdClientOpBase:get_http_url()
    assert(false, "should not reach here")
    return false, ""
end

function EtcdClientOpBase:get_http_content()
    assert(false, "should not reach here")
    return ""
end

function EtcdClientOpBase:execute(etcd_client)
    assert(false, "should not reach here")
    return 0
end

function EtcdClientOpBase:concat_values(keys_tb, kv_format, sep)
    local ret_strs = {}
    for i, key in ipairs(keys_tb) do
        if self[key] then
            ret_strs[#ret_strs + 1] = string.format(kv_format, key, self[key])
        end
    end
    local ret_str = table.concat(ret_strs, sep)
    return ret_str
end

function EtcdClientOpBase._Handle_event_cb(op, op_id, err_type_enum, err_num_int)
    log_debug("EtcdClientOpBase._Handle_event_cb %s", op_id)
end

