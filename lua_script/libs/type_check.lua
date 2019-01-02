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