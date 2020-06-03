

---@class EtcdResultDir: EtcdResultBase
EtcdResultDir = EtcdResultDir or class("EtcdResultDir", EtcdResultBase)

function EtcdResultDir:ctor()
    EtcdResultDir.super.ctor(self, Etcd_Result_Type.dir)
end

function EtcdResultDir:reset()
    EtcdResultDir.super.reset(self)
end

function EtcdResultDir:parse_from(op_result)
    EtcdResultDir.super.parse_from(self, op_result)

end