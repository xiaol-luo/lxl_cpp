
local MAX_TRAVERSAL_NUM = 64
local function traversal(t)
	local ret = {}

	local function insert(v)
		table.insert(ret, v)
		if #ret > MAX_TRAVERSAL_NUM then
			error()
		end
	end

	local function tr(v)
		local tp = type(v)
		if v == nil then
			insert("nil, ")

		elseif v == {} then
			insert("{}, ")

		elseif tp == "table" then
			insert(" { ")
			local maxn = 0
			for i, vv in ipairs(v) do
				insert("[" .. i .. "] = ")
				tr(vv)
				maxn = i
			end

			for k, vv in pairs(v) do
				if not (type(k) == "number" and k > 0 and k <= maxn) then
					if type(k) == "number" then
						insert("[" .. k .. "] = ")
					else
						insert(tostring(k) .. " = ")
					end
					tr(vv)
				end
			end
			insert(" } ")

		elseif tp == "string" then
			insert('"' .. v .. '", ')

		else
			insert(tostring(v))
			insert(", ")

		end
	end

	local err = xpcall(function () tr(t) end, function(...) print(...) end )
	if not err then
		table.insert(ret, "...")
	end

	return table.concat(ret)
end

local function getlocalvalue(level)
	level = level or 3
	local ret = {}
	local n = 1
	while true do
		local name, value = debug.getlocal(level, n)
		if not name then break end

		if name ~= "(*temporary)" then
			local tp = type(value)
			if tp ~= "table" and tp ~= "function" and tp ~= "thread" and tp ~= "userdata" then
				ret[name] = tostring(value)
			end
		end

		n = n + 1
	end
	return ret
end

local old_assert = assert
function assert(b, ...)
	if b then
		return b
	end
	
	local tMessage = {...}
	local tOutPut = {"\n"}
	
	local info = debug.getinfo(2, "Slf")
	table.insert(tOutPut, info.source .. "(" .. info.currentline .. ")\n")

	for k, v in ipairs(tMessage) do
		local str
		if type(v) == "table" then
			str = traversal(v)
		else
			str = tostring(v)
		end
		table.insert(tOutPut, "\tMessage[" .. k .. "]: " .. str .. "\n")
	end
	table.insert(tOutPut, "\tLocalValue: " .. traversal(getlocalvalue()) .. "\n")
	old_assert(false, table.concat(tOutPut))
end