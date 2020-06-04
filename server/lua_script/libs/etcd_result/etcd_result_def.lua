
Etcd_Node_Type = {}

function parse_etcd_result_node(node_data, force_as_node)
    local ret = nil
    local is_parse_ok = false
    if node_data then
        if not force_as_node and node_data.dir then
            ret = EtcdResultDir:new()
        else
            ret = EtcdResultNode:new()
        end
        is_parse_ok = ret:parse_from(node_data)
    end
    return is_parse_ok and ret or nil
end
