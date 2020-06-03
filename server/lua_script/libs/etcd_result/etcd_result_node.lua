
---@class EtcdResultNode: EtcdResultBase
EtcdResultNode = EtcdResultNode or class("EtcdResultNode", EtcdResultBase)

function EtcdResultNode:ctor()
    EtcdResultNode.super.ctor(self, Etcd_Result_Type.node)
end

function EtcdResultNode:reset()
    EtcdResultNode.super.reset(self)
end

function EtcdResultNode:parse_from(op_result)
    EtcdResultNode.super.parse_from(self, op_result)

end
