
EtcdClientOpSet = EtcdClientOpSet or class("EtcdClientOptSet", EtcdClientOpBase)

function EtcdClientOpSet:ctor()
    EtcdClientOpSet.super.ctor(self)
    self[EtcdConst.Key] = nil
    self[EtcdConst.Value] = nil
    self[EtcdConst.Ttl] = nil
    self[EtcdConst.Refresh] = nil
    self[EtcdConst.Dir] = nil
    self[EtcdConst.PrevExist] = nil
    self[EtcdConst.PrevIndex] = nil
    self[EtcdConst.PrevValue] = nil
end

function EtcdClientOpSet:get_http_url()
    if not self[EtcdConst.Key] then
        return false, ""
    end
    local ret_str = self[EtcdConst.Key]
    return true, ret_str
end

function EtcdClientOpSet:get_http_content()
    local keys = {
        EtcdConst.Value,
        EtcdConst.Ttl,
        EtcdConst.Refresh,
        EtcdConst.Dir,
        EtcdConst.PrevExist,
        EtcdConst.PrevIndex,
        EtcdConst.PrevValue,
    }
    local kv_foramt = "%s=%s"
    local sep = "&"
    local ret_str = self:concat_values(keys, kv_foramt, sep)
    return ret_str
end

function EtcdClientOpSet:execute(etcd_client)
    local ret, sub_url = self:get_http_url()
    if not ret then
        return 0
    end
    local url = string.format(self.host_format, etcd_client:get_host(), sub_url)
    local content = self:get_http_content()
    local op_id = HttpClient.put(url, content,
            Functional.make_closure(self._handle_result_cb, self),
            Functional.make_closure(self._handle_event_cb, self),
            self.http_heads)
    return op_id;
end

--[[
function EtcdClientOpSet._handle_result_cb(op, op_id, url_str, heads_map, body_str, body_len)
    log_debug("EtcdClientOpSet._handle_result_cb %s %s %s %s %s", op_id or "null", url_str or "null", heads_map or "null", body_str or "", body_len or "null")
end
--]]
