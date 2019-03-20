
EtcdClientCxx = EtcdClientCxx or {}

function EtcdClientCxx.instance_one(host, user_name, pwd)
    local ret = EtcdClient:new(host)
    return ret
end