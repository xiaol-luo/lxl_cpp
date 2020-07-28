

random = random or {}

function random.pick_one(t)
    assert(is_table(t))
    local t_array = table.to_array(t)
    if #t_array <= 0 then
        return nil, nil
    end
    local rand_idx = math.random(1, #t_array)
    local ret = t_array[rand_idx]
    local key, val = ret[1], ret[2]
    return key, val
end