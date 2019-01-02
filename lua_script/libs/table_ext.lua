--[[
说明：
	反转数组的原始排列顺序，返回新建的table,不改变源table
返回值：
	table 新建的table
参数：
	t table 必须是数组
]]
function table.revert(t)
	local len = #t 
	local t2 = {}
	for i = 1, len do
		t2[len + 1 - i] = t[i]
	end
	return t2
end

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
function table.deepclone(t)
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

function table.appendOther(t1, t2)
    for k, v in pairs(t2) do
        t1[k] = v
    end
    return t1
end

function table.addOther(t1, t2)
    for k, v in pairs(t2) do
        local n1 = t1[k] or 0
        t1[k] = v + n1
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

function table.convertnumber(t)
	local ret = {}
	for i,v in pairs(t) do
		ret[i] = tonumber(v)
	end
	return ret
end

function table.suffle(t)
	local len = #t
	for i, v in ipairs(t) do
		local index = random.IRandom(1, len)
		t[i], t[index] = t[index], t[i]
	end
end

function table.find(t, value)
	for k, v in ipairs(t) do
		if v == value then
			return true, k
		end
	end
	return false, 0
end

function table.GetSortedKey(tSrcTable, fSortFun)
    if not fSortFun then
        fSortFun = function (a , b)
            if a < b then 
                return true
            end
        end
    end

    local tKey = {}
    for key, _ in pairs(tSrcTable) do
        table.insert(tKey, key)
    end
    table.sort(tKey, fSortFun)
    return tKey
end

function table.etValues(t)
    local tValue = {}
    for _, v in pairs(t) do
        table.insert(tValue, v)
    end
    return tValue
end

--[[
	有序迭代器：根据table key的次序来进行遍历。可选参数fSortFun用于指定某种特殊次序。
	以下函数先将key排序到一个数组中，然后迭代这个数组，且每步都返回原table中的key和value。
--]]
function table.PairsByKeys(tSrc, fSortFun)
    local tKey = {}
    for n in pairs(tSrc) do
        tKey[#tKey + 1] = n
    end
    table.sort(tKey, fSortFun)

    local i = 0 --迭代器变量
    return function () --迭代器函数
        i = i + 1
        return tKey[i], tSrc[tKey[i]]
    end
end

function table.min(t)
	local m = t[1]
	for _, v in ipairs(t) do
		if v < m then
			m = v
		end
	end
	return m
end

function table.max(t)
	local m = t[1]
	for _, v in ipairs(t) do
		if v > m then
			m = v
		end
	end
	return m
end

function table.removevalue(t, value)
	for k, v in ipairs(t) do
		if v == value then
			table.remove(t, k)
			break
		end
	end
	return t
end

function table.MaxValue(t)
    local m = 0
    for _, v in pairs(t) do
        if v > m then
            m = v
        end
    end
    return m
end

function table.FindKey(t, value)
    for k, v in pairs(t) do
        if v == value then
            return true, k
        end
    end
    return false, 0
end

function table.lonePart(t, nCount)
    local tRt = {}
    if size(t) <= nCount then
        tRt = clone(t)
    else
        for i=1, nCount do
            insert(tRt, t[i])         
        end
    end
    return tRt
end

function table.minn(t)
    local tSortedKey = GetSortedKey(t)
    for _, k in ipairs(tSortedKey) do
        return k
    end
    return 0
end

function table.ConvertToArr(t)
    local tArr = {}
    for k, v in pairs(t) do
        table.insert(tArr, {k, v})
    end
    return tArr
end

function table.walk(t, func)
    for k, v in pairs(t) do
        func(k, v)
    end
end

function table.keys(hash_table)
    local keys = {}
    for k, v in pairs(hash_table) do
    	table.insert(keys, k)
    end
    return keys
end 

function table.walksort(t, sort_func, walk_func)
	local keys = table.keys(t)
	table.sort(keys, function(lkey, rkey) return sort_func(lkey, rkey) end )

	for i = 1, #keys do
		walk_func(keys[i], t[keys[i]])
	end
end


-- 从数组中查找指定值，返回其索引，没找到返回false
function table.indexof(array, value, begin)
    for i = begin or 1, #array do
        if array[i] == value then 
			return i 
		end
    end
	return false
end