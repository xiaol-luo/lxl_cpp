--[[
说明：
	浅层次克隆一个hash表，并不递归克隆
返回值：
	table 新建的table
参数：
	t table 源hash表
]]
function table.clone(t)
	local u = setmetatable({}, getmetatable(t))
	for i, v in pairs(t) do
		u[i] = v
	end
	return u
end

--[[
说明：
	递归深度克隆一个hash表
返回值：
	table 新建的table
参数：
	t table 源hash表
]]
function table.deep_clone(t)
	local r = {}
	local index = {[t] = r}

	local function clone_(dst, src)
		for i, v in pairs(src) do
			if type(v) == "table" then
				if not index[v] then
					index[v] = {}
					dst[i] = clone_(index[v], v)
				else
					dst[i] = index[v]
				end
			else
				dst[i] = v
			end
		end

		setmetatable(dst, getmetatable(src))
		return dst
	end

	return clone_(r, t)
end

function table.append(t1, t2)
	for _, v in ipairs(t2) do
		table.insert(t1, v)
	end
	return t1
end

function table.size(t)
	local n = 0
	for _, v in pairs(t) do
		n = n + 1
	end
	return n
end

function table.keys(hash_table)
	local ret = {}
	for k, _ in pairs(hash_table) do
		table.insert(ret, k)
	end
	return ret
end

function table.values(t)
    local ret = {}
    for _, v in pairs(t) do
        table.insert(ret, v)
    end
    return ret
end

function table.remove_value(t, value)
	local is_reoved = false
	for k, v in ipairs(t) do
		if v == value then
			table.remove(t, k)
			is_reoved = true
			break
		end
	end
	return is_reoved
end

function table.find_key(t, value)
    for k, v in pairs(t) do
        if v == value then
            return true, k
        end
    end
    return false, 0
end

function table.to_array(t)
    local tArr = {}
    for k, v in pairs(t) do
        table.insert(tArr, {k, v})
    end
    return tArr
end

function table.for_each(t, func)
    for k, v in pairs(t) do
        func(k, v)
    end
end

function table.gen_weak_table(mode)
	local t = {}
	setmetatable(t, {__mode = mode})
	return t
end