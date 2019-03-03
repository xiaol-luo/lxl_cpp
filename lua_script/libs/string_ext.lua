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
    local iterator = function() return string.find(s, sep, pos) end -- 这里采用非朴素搜索，即sep可以是类似正则表达式子的东西
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
说明：
	将数组转化成字符串(只能是数组，不能是hash表)
返回值：
	string 字符串
参数：
	t table 源数组
	sep string 可选参数 分隔字符 默认为','
	注意：数组中的元素如果是字符串，则可能包含sep，这将会影响strtoarr的转换，因此需要处理下
]]
local tRepChars = 
{
	[","] = "，",
	[";"] = "；",
}
function string.arrtostr(t, sep)
	if #t == 0 then return "" end

	sep = sep or ','
	local r = {}
	for _, v in ipairs(t) do
		if type(v) == "string" then
			v = string.gsub(v, sep, tRepChars)
		end
		table.insert(r, v)
	end
	return table.concat(r, sep) .. sep
end

--[[
说明：
	将字符串转换成数组
返回值：
	table 数组
参数：
	s string 源字符串
	sep string 可选参数 分隔字符 默认为','
	fconvert function 可选参数 分隔后的数组中的元素全是字符串，可以传个转换函数将其转成所需要的类型
]]
function string.strtoarr(s, sep, fconvert)
	sep = sep or ','
	if fconvert then
		assert(type(fconvert) == "function")
	end

	local r = string.split(s, sep)
	if fconvert then
		for i, v in ipairs(r) do
			r[i] = fconvert(v)
		end
	end

	return r
end

--[[
说明：
	将二维的数据转换成字符串
返回值：
	string 字符串
参数：
	t table 源数组
	sep1 string 可选参数 内层数组的分隔符
	sep2 string 可选参数 外层数组的分隔符
	注意：数组中的元素如果是字符串，则可能包含sep，这将会影响strtomultiarr的转换，因此需要处理下
]]

function string.multiarrtostr(t, sep1, sep2)
	if #t == 0 then return "" end

	sep1 = sep1 or ','
	sep2 = sep2 or ';'

	local rep = "[" .. sep1 .. sep2 .. "]"
	local r = {}
	for _, v in ipairs(t) do
		for ii, vv in ipairs(v) do
			if type(vv) == "string" then
				v[ii] = string.gsub(vv, rep, tRepChars)
			end
		end

		table.insert(r, table.concat(v, sep1) .. sep1)
	end
	return table.concat(r, sep2) .. sep2
end

--[[
说明：
	将字符串转换成二维数组
返回值：
	table 数组
参数：
	s string 源字符串
	sep1 string 可选参数 内层数组的分隔符
	sep2 string 可选参数 外层数组的分隔符
	fconvert function 可选参数 分隔后的数组中的元素全是字符串，可以传个转换函数将其转成所需要的类型
]]
function string.strtomultiarr(s, sep1, sep2, fconvert)
	sep1 = sep1 or ','
	sep2 = sep2 or ';'

	local r = {}
	local t = strtoarr(s, sep2)
	for i, v in ipairs(t) do
		table.insert(r, strtoarr(v, sep1, fconvert))
	end
	return r
end

--[[
说明：
	将hash表转换成字符串
返回值：
	string 字符串
参数：
	t table 源hash表
注意:
	t中的key和value中可能包含','和';',这将扰乱strtotbl,所以函数内部直接将其转换成中文中的字符
]]
function string.tbltostr(t, sep1, sep2)
	sep1 = sep1 or ','
	sep2 = sep2 or ';'
	local rep = "[" .. sep1 .. sep2 .. "]"

	local r
	for k, v in pairs(t) do
		if type(k) == "string" then 
			k = string.gsub(k, rep, tRepChars)
		end

		if type(v) == "string" then
			v = string.gsub(v, rep, tRepChars)
		end

		r = not r and string.format("%s%s%s", k, sep1, v) or string.format("%s%s%s%s%s", r, sep2, k, sep1, v)
	end
	return r or ""
end


--[[
说明：
	将字符串转换为hash表
返回值：
	table hash表
参数：
	s string 源字符串
	kconvert function 可选参数 key的类型转换函数(字符串-->想要的类型)
	vconvert function 可选参数 value的类型转换函数(字符串-->想要的类型)
]]
function string.strtotbl(s, sep1, sep2, kconvert, vconvert)
	sep1 = sep1 or ','
	sep2 = sep2 or ';'
	local t = strtomultiarr(s, sep1, sep2)
	local r = {}
	for _, v in ipairs(t) do
		local kk, vv = unpack(v)
		if kk and vv then
			if kconvert then
				kk = kconvert(kk)
			end

			if vconvert then
				vv = vconvert(vv)
			end
			r[kk] = vv
		end
	end
	return r
end

--[[
说明：
	序列化整个tabel(可被直接反序列化),可以嵌套table,可以是hash表和数组或者两者的混合
返回值：
	string 字符串
参数：
	t table 源table
]]
function string.serialize(t)
	local names = {}
	local assigns = {}

	local function ser(t1, name)
		names[t1] = name
		local items = {}
		for k, v in pairs(t1) do
			local tp = type(k)
			local key
			if tp == "string" then
				key = string.format("[%q]", k)
			elseif tp == "number" or tp == "boolean" then
				key = string.format("[%s]", tostring(k))
			else
				assert(false, "the key of serializable type only support 'string', 'number' and 'boolean'")
			end

			tp = type(v)
			if tp == "string" then
				table.insert(items, string.format("%s=%q", key, v))
			elseif tp == "number" or tp == "boolean" then
				table.insert(items, string.format("%s=%s", key, tostring(v)))
			elseif tp == "table" then
				local tbl_name = string.format("%s%s", name, key)
				if names[v] then
					table.insert(assigns, string.format("%s=%s", tbl_name, names[v]))
				else
					table.insert(items, string.format("%s=%s", key, ser(v, tbl_name)))
				end
			else
				assert(false, "the value of serializable type only support 'string', 'number', 'boolean' and 'table'")
			end
		end
		return string.format("{%s}", table.concat(items, ","))
	end

	local ret_str = ser(t, "ret")
	local assign_str = table.concat(assigns, " ")
	return string.format("do local ret = %s %s return ret end", ret_str, assign_str)
end

--[[
说明：
	反序列化字符串为table
返回值：
	table hashb表
参数：
	s string 源字符串
]]
function string.unserialize(s)
	local f = load(s)
	assert(f, string.format("string unserialize to table error. string:%s", s))
	return f()
end

--[[
说明：
	获取hash表的打印排版后的字符串，专门用于打印输出
返回值：
	string 经过排版后的字符串
参数：
	t table 源hash表
	maxlevel number 可选参数 hash表展开的层数 默认全部展开
]]
function string.toprint(t, maxlevel)
	if not IsTable(t) then
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
			elseif tp == "number" or tp == "boolean" or tp == "function" then
				str = string.format("%s = %s,", key, tostring(v))
			elseif tp == "table" then
				if names[v] then
					str = string.format("%s = %s,", key, names[v])
				else
					str = string.format("%s = %s,", key, ser(v, string.format("%s%s", name, key), level+1))
				end
			else
				assert(false, "value type unsupported")
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

function string.utf8len(input)
	AssertString(input)
	local lengthList = {}
    local len  = string.len(input)
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                local tempLength = i
                if tempLength > 4 then
                	tempLength = 4
                end
                table.insert(lengthList, tempLength)
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt, lengthList
end

function string.utf8sub(input, nStart, nEnd)
	AssertString(input)
	AssertNumber(nStart)
	AssertNumber(nEnd)
	local len  = string.len(input)
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}	
    local nStrStart = 1
    local nStrEnd = len

    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
        if nStart == cnt then
        	nStrStart = -left
        elseif nEnd == cnt then
        	nStrEnd = -(left + 1)
        end
    end

    return string.sub(input, nStrStart, nStrEnd)
end


function string.unicode_to_utf8(convertStr)

    if type(convertStr) ~= "string" then
        return convertStr
    end
    
    local resultStr=""
    local i=1
    while true do
        
        local num1=string.byte(convertStr,i)
        local unicode
        
        if num1~=nil and string.sub(convertStr,i,i+1)=="\\u" then
            unicode=tonumber("0x"..string.sub(convertStr,i+2,i+5))
            i=i+6
        elseif num1~=nil then
            unicode=num1
            i=i+1
        else
            break
        end
  
        if unicode <= 0x007f then
            resultStr=resultStr..string.char(bit.band(unicode,0x7f))

        elseif unicode >= 0x0080 and unicode <= 0x07ff then
            resultStr=resultStr..string.char(bit.bor(0xc0,bit.band(bit.rshift(unicode,6),0x1f)))
            resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))

        elseif unicode >= 0x0800 and unicode <= 0xffff then
            resultStr=resultStr..string.char(bit.bor(0xe0,bit.band(bit.rshift(unicode,12),0x0f)))
            resultStr=resultStr..string.char(bit.bor(0x80,bit.band(bit.rshift(unicode,6),0x3f)))
            resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))

        end
    
    end
    
    return resultStr
end
--获取名字的长度， 一个中文算两个字符的特殊处理
function string.get_spec_length(str)
	AssertString(str)
	local _, lenghtList = string.utf8len(str)
	local nLenght = 0
	for i, v in ipairs(lenghtList) do
		if v >= 2 then
			nLenght = nLenght + 2
		else	
			nLenght = nLenght + v
		end
	end
	return nLenght
end

--把utf8 字符串拆分出来
function string.utf8_StringToChars( str )
	local begin_index = 0
	local end_index = 0 
	local list = {}
	for k = 1, #str do 
		local c = string.byte(str, k)  
		end_index = end_index + 1
		if bit.band(c, 0xc0) ~= 0x80 then
			if end_index > 1 then
				table.insert(list, string.sub(str, begin_index, end_index-1))
				begin_index = end_index
			end
		end
		if k == #str then
			table.insert(list, string.sub(str, begin_index, #str))
		end
	end
	return list
end

-- 聊天相关'#'字符处理
function string.FiltByChatWnd(str)
	AssertString(str)
	str = string.gsub(str, "#", "##")
	return str
end

--获取richText文本的长度,暂时支持文字(无样式)和表情
function string.getLengthOfRichText(str)
	--过滤非法,方便计数
	local length = 0
	local waitExpression = false
	local i = 1
	while i <= string.len(str) do
		local c = string.byte(str, i) 
		if bit.band(c, 0xc0) ~= 0x80 then
			length = length + 1
		end
		i = i + 1
	end
	return length
end

-- 在utf8字符串的每一个字符之间插入一个字符
function string.InsertCharBetweenStr(szStr, szChar)
	AssertString(szStr)
	AssertString(szChar)	
	local szRet = ""
	local nPreIndex = 1
	local i = 1
	local nLen = string.len(szStr)
	while i <= nLen do
		local c = string.byte(szStr, i)
		if bit.band(c, 0xc0) ~= 0x80 and i > 1 then
			szRet = szRet .. string.sub(szStr, nPreIndex, i - 1) .. szChar
			nPreIndex = i
		end		
		i = i + 1
	end
	szRet = szRet .. string.sub(szStr, nPreIndex, nLen)
	return szRet
end

--删除一个richText,暂时支持文字(无样式)和表情
function string.deleteOneRichChar( str )
	--最后一个是表情
	local new_str, num = string.gsub(str, "#IS%([^()]*%)$", "")
	if num > 0 then
		return new_str
	end

	for i = string.len(str), 1, -1 do 
		local c = string.byte(str, i) 
		if bit.band(c, 0xc0) ~= 0x80 then
			return string.sub(str, 1, i-1)
		end 
	end
end

--暂时支持文字(无样式)和表情
function string.deleteRichChar( str, count )
	count = count or 1
	local newStr = str
	for i = 1, count do
		newStr = deleteOneRichChar(newStr)
	end
	return newStr
end

--限制richChar的长度
function string.limitRichChar( str , limit)
	local curLength = getLengthOfRichText(str)
	if curLength > limit then
		return deleteRichChar(str, curLength - limit).."..."
	else
		return str
	end
end

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
function string.lrtrim( str )
	return string.rtrim(string.ltrim(str))
end

function string.contains(str, pattern, plain)
	plain = plain or false
	local pos_begin, pos_end = string.find(str, pattern, 1, plain)
	return pos_begin ~= nil
end

function string.startswith(str, pattern, plain)
	plain = plain or false
	local pos_begin, pos_end = string.find(str, pattern, 1, plain)
	return pos_begin == 1
end

function string.endswith(str, pattern, plain)
	plain = plain or false
	local pos_begin, pos_end = string.find(str, pattern, -#pattern, plain)
	return pos_end == #str
end

CHAR_VAL_a = string.byte('a')
CHAR_VAL_z = string.byte('z')
CHAR_VAL_A = string.byte('A')
CHAR_VAL_Z = string.byte('Z')
CHAR_VAL_0 = string.byte('0')
CHAR_VAL_9 = string.byte('9')

function string.isalnum(str)
    local ret = false
    if str then
        ret = true
        for _, v in ipairs({string.byte(str, 1, #str)}) do
            local in_range = false
            if not in_range and CHAR_VAL_a <= v and v <= CHAR_VAL_z then
                in_range = true
            end
            if not in_range and CHAR_VAL_A <= v and v <= CHAR_VAL_Z then
                in_range = true
            end
            if not in_range and CHAR_VAL_0 <= v and v <= CHAR_VAL_9 then
                in_range = true
            end
            if not in_range then
                ret = false
                break
            end
        end
    end
    return ret
end

function string.isalpha(str)
    local ret = false
    if str then
        ret = true
        for _, v in ipairs({string.byte(str, 1, #str)}) do
            local in_range = false
            if not in_range and CHAR_VAL_a <= v and v <= CHAR_VAL_z then
                in_range = true
            end
            if not in_range and CHAR_VAL_A <= v and v <= CHAR_VAL_Z then
                in_range = true
            end
            if not in_range then
                ret = false
                break
            end
        end
    end
    return ret
end

function string.isnum(str)
    local ret = false
    if str then
        ret = true
        for _, v in ipairs({string.byte(str, 1, #str)}) do
            if v < CHAR_VAL_0 or v > CHAR_VAL_9 then
                ret = false
                break
            end
        end
    end
    return ret
end

