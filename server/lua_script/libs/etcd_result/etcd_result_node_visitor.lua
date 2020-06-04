
local extract_next_kv = function(node, index)
    log_print(string.format("extract_next_kv kv!!!!!!!! is_dir=%s tb=%s index=%s", node:is_dir_node(), tostring(node), tostring(index)))

    local tb = node

    local k, v = nil
    if node:is_dir_node() then
        if nil == index then
            log_print("extract_next_kv", 1)
            k, v = node, node
        else
            log_print("extract_next_kv", 2)
            local real_index = index
            if real_index == node then
                log_print("extract_next_kv", 3)
                real_index = nil
            end
            if node.value then
                log_print("extract_next_kv", 4)
                tb = node.value
                k, v = next(node.value, real_index)
            end
        end
    else
        log_print("extra_meta_extract_next_kv", 5)
        if nil == index then
            k, v = node, node
        end
    end

    log_print(string.format("extract_next_kv reslut!!!! is_dir=%s tb=%s k=%s v=%s\n\n\n", node:is_dir_node(), tostring(tb),  tostring(k), tostring(v)))
    return k, v
end

local visit_next =  function(wait_visit_nodes, self, index)
    local k, v = nil, nil
    local using_index = index
    if #wait_visit_nodes > 0 then
        repeat
            local visit_node = wait_visit_nodes[1]
            k, v = extract_next_kv(visit_node, using_index)
            if v then
                if v ~= visit_node and v:is_dir_node() then
                    table.append(wait_visit_nodes, v.value)
                end
                break
            else
                using_index = nil
                table.remove(wait_visit_nodes, 1)
            end
        until #wait_visit_nodes <= 0
    end
    return k, v
end

local visit_next_dir = function(wait_visit_nodes, self, index)
    local k, v = nil
    local real_index = index
    repeat
        k, v = visit_next(wait_visit_nodes, self, real_index)
        real_index = k
    until nil == v or v:is_dir_node()
    return k, v
end

local visit_next_node = function(wait_visit_nodes, self, index)
    local k, v = nil
    local real_index = index
    repeat
        k, v = visit_next(wait_visit_nodes, self, real_index)
        real_index = k
    until nil == v or not v:is_dir_node()
    return k, v
end

local extra_meta = {}
function extra_meta.__pairs(self)
    return self:iter()
end

EtcdResultNodeVisitor = EtcdResultNodeVisitor or class("EtcdResultNodeVisitor", nil, extra_meta)

function EtcdResultNodeVisitor:ctor(node)
    self.node = node
end

function EtcdResultNodeVisitor:iter()
    local wait_visit_nodes = {}
    table.insert(wait_visit_nodes, self.node)
    local iter_fn = Functional.make_closure(visit_next, wait_visit_nodes)
    return iter_fn, self, nil
end

function EtcdResultNodeVisitor:iter_dir()
    local wait_visit_nodes = {}
    table.insert(wait_visit_nodes, self.node)
    local iter_fn = Functional.make_closure(visit_next_dir, wait_visit_nodes)
    return iter_fn, self, nil
end


function EtcdResultNodeVisitor:iter_node()
    local wait_visit_nodes = {}
    table.insert(wait_visit_nodes, self.node)
    local iter_fn = Functional.make_closure(visit_next_node, wait_visit_nodes)
    return iter_fn, self, nil
end




