
---@class EtcdResultWatch: EtcdResultBase
EtcdResultWatch = EtcdResultWatch or class("EtcdResultWatch", EtcdResultBase)

function EtcdResultWatch:ctor()
    EtcdResultWatch.super.ctor(self, Etcd_Result_Type.watch)
end

function EtcdResultWatch:reset()
    EtcdResultWatch.super.reset(self)
end

function EtcdResultWatch:parse_from(op_result)
    EtcdResultWatch.super.parse_from(self, op_result)

end
