
---@class EtcdClientOpGet : EtcdClientOpBase
EtcdClientOpGet = EtcdClientOpGet or class("EtcdClientOpGet", EtcdClientOpBase)

function EtcdClientOpGet:ctor()
    EtcdClientOpSet.super.ctor(self)
    self[Etcd_Const.Key] = nil
    self[Etcd_Const.Wait] = nil
    self[Etcd_Const.Recursive] = nil
    self[Etcd_Const.WaitIndex] = nil
    self[Etcd_Const.PrevExist] = nil
    self[Etcd_Const.PrevIndex] = nil
    self[Etcd_Const.PrevValue] = nil
end

function EtcdClientOpGet:get_http_url()
    if not self[Etcd_Const.Key] then
        return false, ""
    end
    local keys = {
        Etcd_Const.Wait,
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

function EtcdClientOpGet:execute(etcd_client, host_idx)
    local ret, sub_url = self:get_http_url()
    if not ret then
        return 0
    end
    local host = etcd_client:get_host(host_idx)
    if nil == host_idx then
        return 0
    end
    local url = string.format(self.host_format, host, sub_url)
    self.running_op_id = HttpClient.get(url,
            Functional.make_closure(self._handle_result_cb, self, etcd_client, host_idx),
            Functional.make_closure(self._handle_event_cb, self, etcd_client, host_idx),
            etcd_client:get_heads(self.http_heads))
    if not self.op_id then
        self.op_id = self.running_op_id
    end
    return self.running_op_id
end
