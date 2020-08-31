
---@class EtcdClientOpSet : EtcdClientOpBase
EtcdClientOpSet = EtcdClientOpSet or class("EtcdClientOptSet", EtcdClientOpBase)

function EtcdClientOpSet:ctor()
    EtcdClientOpSet.super.ctor(self)
    self[Etcd_Const.Key] = nil
    self[Etcd_Const.Value] = nil
    self[Etcd_Const.Ttl] = nil
    self[Etcd_Const.Refresh] = nil
    self[Etcd_Const.Dir] = nil
    self[Etcd_Const.PrevExist] = nil
    self[Etcd_Const.PrevIndex] = nil
    self[Etcd_Const.PrevValue] = nil
end

function EtcdClientOpSet:get_http_url()
    if not self[Etcd_Const.Key] then
        return false, ""
    end
    local ret_str = self[Etcd_Const.Key]
    return true, ret_str
end

function EtcdClientOpSet:get_http_content()
    local keys = {
        Etcd_Const.Value,
        Etcd_Const.Ttl,
        Etcd_Const.Refresh,
        Etcd_Const.Dir,
        Etcd_Const.PrevExist,
        Etcd_Const.PrevIndex,
        Etcd_Const.PrevValue,
    }
    local kv_foramt = "%s=%s"
    local sep = "&"
    local ret_str = self:concat_values(keys, kv_foramt, sep)
    return ret_str
end

function EtcdClientOpSet:execute(etcd_client, host_idx)
    local ret, sub_url = self:get_http_url()
    if not ret then
        return 0
    end
    local host = etcd_client:get_host(host_idx)
    if nil == host_idx then
        return 0
    end
    local url = string.format(self.host_format, host, sub_url)
    local content = self:get_http_content()
    self.running_op_id = HttpClient.put(url, content,
            Functional.make_closure(self._handle_result_cb, self, etcd_client, host_idx),
            Functional.make_closure(self._handle_event_cb, self, etcd_client, host_idx),
            etcd_client:get_heads(self.http_heads))
    if not self.op_id then
        self.op_id = self.running_op_id
    end
    return self.running_op_id
end
