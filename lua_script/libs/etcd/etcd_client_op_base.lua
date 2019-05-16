
EtcdClientOpBase = EtcdClientOpBase or class("EtcdClientOpBase")

function EtcdClientOpBase:ctor()
    self.host_format = "%s/v2/keys%s"
    self.http_heads = {}
    self.http_heads["Content-Type"] = "application/x-www-form-urlencoded"
    self.cb_fn = nil -- function(op_id, op, op_result) end
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
    -- log_debug("EtcdClientOpBase:concat_values %s", ret_str)
    return ret_str
end

function EtcdClientOpBase:_handle_event_cb(op_id, etcd_event, err_num)
    -- log_debug("EtcdClientOpBase._Handle_event_cb %s %s %s",  op_id or "null", err_type_enum or "null", err_num or "null")
    if 0 ~= err_num then
        local ret = EtcdClientResult:new()
        ret.fail_event = etcd_event
        ret.fail_code = err_num
        if self.cb_fn then
            self.cb_fn(op_id, self, ret)
        end
    end
end

function EtcdClientOpBase:_handle_result_cb(op_id, rsp_state, heads_map, body_str)
    -- log_debug("EtcdClientOpBase._handle_result_cb._handle_result_cb op_id:%s rsp_state:%s head_map:%s bodoy_str:%s ",
    --       op_id or "null", rsp_state or "null", heads_map or "null", body_str or "null")
    if not self.cb_fn then
        return
    end
    local ret = EtcdClientResult:new()
    ret[EtcdConst.Rsp_State] = rsp_state
    if body_str then
        ret:prase_op_result(body_str)
    else
        ret.op_result = {}
    end
    local keys = { EtcdConst.Head_Cluster_Id, EtcdConst.Head_Index, EtcdConst.Head_Raft_Index, EtcdConst.Head_Raft_Term }
    for _, key in pairs(keys) do
        if heads_map[key] then
            ret.op_result[key] = heads_map[key]
        end
    end
    self.cb_fn(op_id, self, ret)
end

