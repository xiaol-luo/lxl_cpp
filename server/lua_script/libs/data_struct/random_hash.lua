

local extra_meta = {}
function extra_meta.__pairs(self)
    return self._next, self, nil
end


---@class RandomHash
RandomHash = RandomHash or class("RandomHash", nil, extra_meta)

function RandomHash:ctor()
    self._hash_map = {}
    self._array = {}
end

function RandomHash:is_exist(key)
    return nil ~= self._hash_map[key]
end

function RandomHash:get(key)
    local ret = nil
    local item = self._hash_map[key]
    if item then
        ret = item.value
    end
    return ret
end

function RandomHash:add(key, value)
    if nil == key or nil == value then
        return false
    end
    if self:is_exist(key) then
        return false
    end
    local item = {
        key = key,
        value = value,
        array_idx = nil,
    }
    self._array[#self._array + 1] = item
    item.array_idx = #self._array
    self._hash_map[key] = item
    return true
end

function RandomHash:remove(key)
    local item = self._hash_map[key]
    if item then
        self._hash_map[key] = nil
        if item.array_idx ~= #self._array then
            local move_item = self._array[#self._array]
            self._array[item.array_idx] = move_item
            move_item.array_idx = item.array_idx
        end
        self._array[#self._array] = nil
    end
end

function RandomHash:random()
    local key, val = nil, nil
    if #self._array > 0 then
        local rand_val = math.random(1, #self._array)
        local pick_item = self._array[rand_val]
        key = pick_item.key
        val = pick_item.value
    end
    return val, key
end

function RandomHash._next(self, index)
    local val = nil
    local key, item = next(self._hash_map, index)
    if item then
        val = item.value
    end
    return key, val
end

function RandomHash:size()
    return #self._array
end

function RandomHash:get_by_index(idx)
    if idx <= 0 or idx > #self._array then
        return nil, nil
    end
    return self._array[idx].val, self._array[idx].key
end