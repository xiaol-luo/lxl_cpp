local mod = {}

local a = 1
g_var = 1

local function foobar()
	return a
end

function mod.get_fn()
	return foobar
end

function mod.set_a(x)
	a = x
	print("this is Old set_a a=", a)
end

local meta = {}
meta.__index = meta

function meta:show()
	print("this is mod show OLD, a=", a)
end

function mod.new()
	return setmetatable({}, meta)
end

return mod