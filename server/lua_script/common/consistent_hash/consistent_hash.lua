
local ConsistentHash_gc = function(self)
    if self._consistent_hash then
        self._consistent_hash = nil
    end
end

local Virtual_Node_Num = 64

ConsistentHash = ConsistentHash or class("ConsistentHash", nil, { __gc = ConsistentHash_gc })

function ConsistentHash:ctor()
    self._consistent_hash = native.ConsistentHash:new()
end

function ConsistentHash:upsert_node(node_name)
    return self._consistent_hash:set_real_node(node_name, Virtual_Node_Num)
end

function ConsistentHash:delete_node(node_name)
    return self._consistent_hash:set_real_node(node_name, 0)
end

function ConsistentHash:find_address(val)
    if "number" == type(val) or "string" == type(val) then
        return self._consistent_hash:find_address(val)
    else
        log_warn("ConsistentHash:find_address input value should be number or string, but now is %s, %s", type(val), debug.traceback())
        return false, ""
    end
end
