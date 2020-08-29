
---@alias EtcdClientOpCB fun(op_id:number, op:EtcdClientOpBase, op_result:EtcdClientResult):void

---@class EtcdClientOpBase
---@field cb_fn EtcdClientOpCB
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

---@param etcd_client EtcdClient
function EtcdClientOpBase:execute(etcd_client)
    assert(false, "should not reach here")
    return 0
end

---@param keys_tb table<string, string>
---@param kv_format string
---@param sep string
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

---@param ret HttpClientEventResult
function EtcdClientOpBase:_handle_event_cb(ret)

end

---@param ret HttpClientRspResult
function EtcdClientOpBase:_handle_result_cb(ret)
    if not self.cb_fn then
        return
    end

    local op_id, rsp_state, heads_map, body_str = ret.id, ret.state, ret.heads, ret.body
    local ret = EtcdClientResult:new()
    ret[Etcd_Const.Rsp_State] = rsp_state
    if not is_rsp_ok(rsp_state) then
        ret.error_msg = rsp_state .. body_str
    else
        if body_str then
            ret:prase_op_result(body_str)
        else
            ret.op_result = {}
        end
        for _, key in pairs({
            Etcd_Const.Head_Cluster_Id,
            Etcd_Const.Head_Index,
            Etcd_Const.Head_Raft_Index,
            Etcd_Const.Head_Raft_Term }) do
            if heads_map[key] then
                ret.op_result[key] = heads_map[key]
            end
        end
    end

    self.cb_fn(op_id, self, ret)
end

