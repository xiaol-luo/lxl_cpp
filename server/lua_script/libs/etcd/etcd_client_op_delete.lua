
---@class EtcdClientOpDelete : EtcdClientOpBase
EtcdClientOpDelete = EtcdClientOpDelete or class("EtcdClientOpDelete", EtcdClientOpBase)

function EtcdClientOpDelete:ctor()
    EtcdClientOpSet.super.ctor(self)
    self[Etcd_Const.Key] = nil
    self[Etcd_Const.Wait] = nil
    self[Etcd_Const.Recursive] = nil
    self[Etcd_Const.WaitIndex] = nil
    self[Etcd_Const.PrevExist] = nil
    self[Etcd_Const.PrevIndex] = nil
    self[Etcd_Const.PrevValue] = nil
end

function EtcdClientOpDelete:get_http_url()
    if not self[Etcd_Const.Key] then
        return false, ""
    end
    local keys = {
        Etcd_Const.Recursive,
        Etcd_Const.WaitIndex,
        Etcd_Const.PrevExist,
        Etcd_Const.PrevIndex,
        Etcd_Const.PrevValue,
    }
    local query_str = self:concat_values(keys, "%s=%s", "&")
    local ret_str = ""
    if #query_str > 0 then
        ret_str = string.format("%s?%s", self[Etcd_Const.Key], query_str)
    else
        ret_str = self[Etcd_Const.Key]
    end
    return true, ret_str
end

function EtcdClientOpDelete:get_http_content()
    local keys = {
    }
    local kv_foramt = "%s=%s"
    local sep = "&"
    local ret_str = self:concat_values(keys, kv_foramt, sep)
    return ret_str
end

function EtcdClientOpDelete:execute(etcd_client, host_idx)
    local ret, sub_url = self:get_http_url()
    if not ret then
        return 0
    end
    local host = etcd_client:get_host(host_idx)
    if nil == host_idx then
        return 0
    end
    local url = string.format(self.host_format, host, sub_url)
    local op_id = HttpClient.delete(url,
            Functional.make_closure(self._handle_result_cb, self, etcd_client, host_idx),
            Functional.make_closure(self._handle_event_cb, self, etcd_client, host_idx),
            etcd_client:get_heads(self.http_heads))
    return op_id;
end
