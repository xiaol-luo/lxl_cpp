--[[
说明：
	根据分隔符（或者分隔符的正则式）来切分字符串
返回值：
	table 包含各个被切分的字符串的数组
参数：
	s string 源字符串
	sep string 分隔符或者分隔符的正则表达式
]]
function string.split(s, sep)
	s = tostring(s)
	sep = tostring(sep)
	assert(sep ~= '')

	if string.len(s) == 0 then return {} end

    local pos, r = 0, {}
    local iterator = function() return string.find(s, sep, pos, true) end
    for pos_b, pos_e in iterator do
        table.insert(r, string.sub(s, pos, pos_b - 1))
        pos = pos_e + 1
    end
    s = string.sub(s, pos)
    if string.len(s) > 0 then
        table.insert(r, s)
    end
    return r
end

--[[
	获取hash表的打印排版后的字符串，专门用于打印输出
返回值：
	string 经过排版后的字符串
参数：
	t table 源hash表
	maxlevel number 可选参数 hash表展开的层数 默认全部展开
]]
function string.to_print(t, maxlevel)
	if nil == t then
		return ""
	end
	if not is_table(t) then
		return tostring(t)
	end

	maxlevel = maxlevel or 0
	local names = {}

	local function ser(t1, name, level)
		if maxlevel > 0 and level > maxlevel then
			return "{...}"
		end

		names[t1] = name
		local items = {}
		for k, v in pairs(t1) do
			local key
			local tp = type(k)
			if tp == "string" then
				key = string.format("[%q]", k)
			elseif tp == "number" or tp == "boolean" or tp == "table" or tp == "function" then
				key = string.format("[%s]", tostring(k))
			else
				assert(false, "key type unsupported")
			end

			tp = type(v)
			local str
			if tp == "string" then
				str = string.format("%s = %q,", key, v)
			elseif tp == "number" or tp == "boolean" or tp == "function" or tp == "userdata" or tp == "thread" then
				str = string.format("%s = %s,", key, tostring(v))
			elseif tp == "table" then
				if names[v] then
					str = string.format("%s = %s,", key, names[v])
				else
					str = string.format("%s = %s,", key, ser(v, string.format("%s%s", name, key), level+1))
				end
			else
				assert(false, "value type unsupported: " .. tp)

			end
			str = string.format("%s%s", string.rep("\t", level), str)
			table.insert(items, str)
		end

		if #items == 0 then
			return "{}"
		end

		local tabs = string.rep("\t", level - 1)
		local ret
		if level ~= 1 then
			ret = string.format("\n%s{\n%s\n%s}", tabs, table.concat(items, "\n"), tabs)
		else
			ret = string.format("%s{\n%s\n%s}", tabs, table.concat(items, "\n"), tabs)
		end
		return ret
	end

	return ser(t, "$self", 1)
end

--去除后面的空格,换行
function string.rtrim(str, chs)
	local chs_val = {}
	for _, v in ipairs({string.byte(chs, 1, #chs)}) do
		chs_val[v] = true
	end
	local idx = 0
	for i = #str,1,-1 do
		if not chs_val[string.byte(str, i)] then
			idx = i
			break
		end
	end
	return idx < 1 and "" or string.sub(str,1, idx)
end

--去除前面的空格,换行
function string.ltrim(str, chs)
	local chs_val = {}
	for _, v in ipairs({string.byte(chs, 1, #chs)}) do
		chs_val[v] = true
	end
	local idx = #str + 1
	for i = 1, #str do
		if not chs_val[string.byte(str, i)] then
			idx = i
			break
		end
	end
	return idx > #str and "" or string.sub(str,idx)
end

--去除前后的空格和换行
function string.lrtrim(str, chs)
	return string.rtrim(string.ltrim(str, chs), chs)
end


