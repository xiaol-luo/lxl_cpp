require "libs.math_ext"

function IsNil(v)
	return type(v) == "nil"
end

function IsBoolean(v)
	return type(v) == "boolean"
end

function IsNumber(v)
	return math.finite(v)
end

function IsString(v)
	return type(v) == "string"
end

function IsTable(v)
	return type(v) == "table"
end

function IsFunction(v)
	return type(v) == "function"
end

function IsThread(v)
	return type(v) == "thread"
end

function IsUserData(v)
	return type(v) == "userdata"
end

function IsClass(Cls)
	if not IsTable(Cls) then return false end

	local __index = rawget(Cls, "__index")
	local __cname = rawget(Cls, "__cname")
	return __index ~= nil and __index == Cls and __cname ~= nil
end

function IsClassInstance(ins, Cls) -- TODO:之后要研究下class.lua，写得更严谨，暂时先这么用
	if not IsTable(ins) then return false end
	if not IsClass(Cls) then return false end
	local _class_type = rawget(ins, "_class_type")
	if not IsTable(_class_type) then return false end
	local ins_cname = rawget(_class_type, "__cname")
	if not ins_cname then return false end
	local cls_cname = rawget(Cls, "__cname")
	if ins_cname ~= cls_cname then
		return false
	end
	return true
end

function AssertNotNil(v, ...)
	assert(type(v) ~= "nil", ...)
	return v
end

function AssertNil(v, ...)
	assert(type(v) == "nil", ...)
	return v
end

function AssertBoolean(v, ...)
	assert(type(v) == "boolean", ...)
	return v
end

function AssertNumber(v, ...)
	assert(math.finite(v), ...)
	return v
end

function AssertString(v, ...)
	 assert(type(v) == "string", ...)
	 return v
end

function AssertTable(v, ...)
	assert(type(v) == "table", ...)
	return v
end

function AssertFunction(v, ...)
	assert(type(v) == "function", ...)
	return v
end

function AssertThread(v, ...)
	assert(type(v) == "thread", ...)
	return v
end

function AssertUserData(v, ...)
	assert(type(v) == "userdata", ...)
	return v
end