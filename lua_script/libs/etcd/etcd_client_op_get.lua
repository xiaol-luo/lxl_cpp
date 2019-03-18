EtcdClientOpGet = EtcdClientOpGet or class("EtcdClientOpGet", EtcdClientOpBase)

function EtcdClientOpGet:ctor()
    EtcdClientOpSet.super.ctor(self)
    self[EtcdConst.Key] = nil
    self[EtcdConst.Wait] = nil
    self[EtcdConst.Recursive] = nil
    self[EtcdConst.WaitIndex] = nil
    self[EtcdConst.PrevExist] = nil
    self[EtcdConst.PrevIndex] = nil
    self[EtcdConst.PrevValue] = nil
end

function EtcdClientOpGet:get_http_url()
    if not self[EtcdConst.Key] then
        return false, ""
    end
    local keys = {
        EtcdConst.Wait,
        EtcdConst.Recursive,
        EtcdConst.WaitIndex,
        EtcdConst.PrevExist,
        EtcdConst.PrevIndex,
        EtcdConst.PrevValue,
    }
    local query_str = self:concat_values(keys, "%s=%s", "&")
    local ret_str = ""
    if #query_str > 0 then
        ret_str = string.format("%s?%s", self[EtcdConst.Key], query_str)
    else
        ret_str = self[EtcdConst.Key]
    end
    return true, ret_str
end

function EtcdClientOpGet:execute(etcd_client)
    local ret, sub_url = self:get_http_url()
    if not ret then
        return 0
    end
    local url = string.format(self.host_format, etcd_client:get_host(), sub_url)
    local op_id = HttpClient.get(url,
            Functional.make_closure(self._handle_result_cb, self),
            Functional.make_closure(self._handle_event_cb, self),
            self.http_heads)
    return op_id;
end


--[[
function EtcdClientOpGet._handle_result_cb(op, op_id, url_str, heads_map, body_str, body_len)
    log_debug("EtcdClientOpGet._handle_result_cb %s %s %s %s %s", op_id or "null", url_str or "null", heads_map or "null", body_str or "", body_len or "null")
end
]]