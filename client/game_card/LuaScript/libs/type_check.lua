
function is_nil(v)
	return type(v) == "nil"
end

function is_boolean(v)
	return type(v) == "boolean"
end

function is_number(v)
	return type(v) == "number"
end

function is_string(v)
	return type(v) == "string"
end

function is_table(v)
	return type(v) == "table"
end

function is_function(v)
	return type(v) == "function"
end

function is_thread(v)
	return type(v) == "thread"
end

function is_userdata(v)
	return type(v) == "userdata"
end

function is_class(Cls)
	if not is_table(Cls) then return false end

	local __index = rawget(Cls, "__index")
	local __cname = rawget(Cls, "__cname")
	return __index ~= nil and __index == Cls and __cname ~= nil
end

function is_class_instance(ins, Cls) -- TODO:之后要研究下class.lua，写得更严谨，暂时先这么用
	if not is_table(ins) then return false end
	if not is_class(Cls) then return false end
	local _class_type = rawget(ins, "_class_type")
	if not is_table(_class_type) then return false end
	local ins_cname = rawget(_class_type, "__cname")
	if not ins_cname then return false end
	local cls_cname = rawget(Cls, "__cname")
	if ins_cname ~= cls_cname then
		return false
	end
	return true
end
