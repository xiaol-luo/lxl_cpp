
---@class EtcdResultDir: EtcdResultNode
EtcdResultDir = EtcdResultDir or class("EtcdResultDir", EtcdResultNode)

function EtcdResultDir:ctor()
    EtcdResultDir.super.ctor(self)
end

function EtcdResultDir:reset()
    EtcdResultDir.super.reset(self)
end

function EtcdResultDir:parse_from(node_data)
    if not node_data.dir then
        return false
    end

    if not EtcdResultDir.super.parse_from(self, node_data) then
        return false
    end

    local is_parse_ok = true
    self.value = {}
    if is_table(node_data.nodes) then
        for _, child_node_data in ipairs(node_data.nodes) do
            local child_etcd_result = parse_etcd_result_node(child_node_data, false)
            if not child_etcd_result then
                is_parse_ok = false
                break
            end
            table.insert(self.value, child_etcd_result)
        end
    end

    return is_parse_ok
end

function EtcdResultDir:is_dir_node()
    return true
end

