
--- api manual: https://etcd.io/docs/v2/api/

---@class EtcdClient
EtcdClient = EtcdClient or class("EtcdClient")

function EtcdClient:ctor(hosts, user, pwd)
    local tmp_hosts = {}
    if is_table(hosts) then
        tmp_hosts = hosts
    end
    if is_string(hosts) then
        tmp_hosts = string.split(hosts, ";")
        log_print("EtcdClient:ctor ", hosts, tmp_hosts)
    end
    self.hosts = {}
    for _, host in pairs(tmp_hosts) do
        table.insert(self.hosts, string.rtrim(host, "/"))
    end
    assert(#self.hosts > 0)
    self.user = user
    self.pwd = pwd
end

---@return string
function EtcdClient:get_hosts()
    return self.hosts
end

function EtcdClient:get_host(host_idx)
    if host_idx > #self.hosts then
        return nil
    else
        return self.hosts[host_idx]
    end
end

---@return table<string, string>
function EtcdClient:get_heads(t)
    local tb = t and table.clone(t) or {}
    if self.user then
        local user_pwd_str = Base64.encode(string.format("%s:%s", self.user, self.pwd or ""))
        tb[Etcd_Const.Authorization] = string.format("Basic %s", user_pwd_str)
    end
    return tb
end

function EtcdClient:example_cb(id, op, result)

end

---@param key string
---@param value string
---@param ttl number
---@param is_dir boolean
---@param cb_fn EtcdClientOpCB
---@return number
function EtcdClient:set(key, value, ttl, is_dir, cb_fn)
    local op = EtcdClientOpSet:new()
    op[Etcd_Const.Key] = key
    op[Etcd_Const.Value] = value
    op[Etcd_Const.Ttl] = ttl
    op[Etcd_Const.Dir] = is_dir and "true" or nil
    op.cb_fn = cb_fn
    return self:execute(op)
end

---@param key string
---@param ttl number
---@param is_dir boolean
---@param cb_fn EtcdClientOpCB
---@return number
function EtcdClient:refresh_ttl(key, ttl, is_dir, cb_fn)
    local op = EtcdClientOpSet:new()
    op[Etcd_Const.Key] = key
    op[Etcd_Const.Ttl] = ttl
    op[Etcd_Const.Dir] = is_dir and "true" or nil
    op[Etcd_Const.PrevExist] = "true"
    op[Etcd_Const.Refresh] = "true"
    op.cb_fn = cb_fn
    return self:execute(op)
end

---@param key string
---@param recursive boolean
---@param cb_fn EtcdClientOpCB
---@return number
function EtcdClient:get(key, recursive, cb_fn)
    local op = EtcdClientOpGet:new()
    op[Etcd_Const.Key] = key
    op[Etcd_Const.Recursive] = recursive and "true" or nil
    op.cb_fn = cb_fn
    return self:execute(op)
end

---@param key string
---@param recursive boolean
---@param cb_fn EtcdClientOpCB
---@return number
function EtcdClient:delete(key, recursive, cb_fn)
    local op = EtcdClientOpDelete:new()
    op[Etcd_Const.Key] = key
    op[Etcd_Const.Recursive] = recursive and "true" or nil
    op.cb_fn = cb_fn
    return self:execute(op)
end

---@param key string
---@param recursive boolean
---@param waitIndex number
---@param cb_fn EtcdClientOpCB
---@return number
function EtcdClient:watch(key, recursive, waitIndex, cb_fn)
    local op = EtcdClientOpGet:new()
    op[Etcd_Const.Key] = key
    op[Etcd_Const.Wait] = "true"
    op[Etcd_Const.WaitIndex] = waitIndex
    op[Etcd_Const.Recursive] = recursive and "true" or nil
    op.cb_fn = cb_fn
    return self:execute(op)
end

---@param key string
---@param prev_index number
---@param prev_value string
---@param value string
---@param cb_fn EtcdClientOpCB
---@return number
function EtcdClient:cmp_swap(key, prev_index, prev_value, value, ttl, cb_fn)
    local op = EtcdClientOpSet:new()
    op[Etcd_Const.Key] = key
    op[Etcd_Const.Value] = value
    op[Etcd_Const.Ttl] = ttl
    op[Etcd_Const.PrevIndex] = prev_index
    op[Etcd_Const.PrevValue] = prev_value
    op[Etcd_Const.PrevExist] = prev_index and  "true" or "false"
    op.cb_fn = cb_fn
    return self:execute(op)
end

---@param key string
---@param prev_index number
---@param prev_value string
---@param value string
---@param cb_fn EtcdClientOpCB
---@return number
function EtcdClient:cmp_delete(key, prev_index, prev_value, recursive, cb_fn)
    local op = EtcdClientOpDelete:new()
    op[Etcd_Const.Key] = key
    op[Etcd_Const.PrevIndex] = prev_index
    op[Etcd_Const.PrevValue] = prev_value
    op[Etcd_Const.Recursive] = recursive and "true" or nil
    op.cb_fn = cb_fn
    return self:execute(op)
end

---@param op EtcdClientOpBase
---@return number
function EtcdClient:execute(op)
    return op:execute(self, 1)
end

function EtcdClient:cancel(op_id)
    HttpClient.cancel(op_id)
end
