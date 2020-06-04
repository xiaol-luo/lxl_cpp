
---@class EtcdResultNode
EtcdResultNode = EtcdResultNode or class("EtcdResultNode")

function EtcdResultNode:ctor()
    self.create_index = nil
    self.modify_index = nil
    self.key = nil
    self.value = nil
    self.is_dir = nil
end

function EtcdResultNode:reset()
    self.create_index = nil
    self.modify_index = nil
end

function EtcdResultNode:parse_from(node_data)
    self.key = node_data[Etcd_Const.Key]
    self.create_index = node_data[Etcd_Const.CreatedIndex]
    self.modify_index = node_data[Etcd_Const.ModifiedIndex]
    self.is_dir = node_data[Etcd_Const.Dir] or false
    self.value = node_data[Etcd_Const.Value]
    return true
end

function EtcdResultNode:is_dir_node()
    return false
end


