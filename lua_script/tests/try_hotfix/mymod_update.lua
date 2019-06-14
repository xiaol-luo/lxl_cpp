
local mod = {}

local a

local function foobar()
	print("this is new foobar")
	return a
end

function mod.get_fn()
	return foobar
end

function mod.set_a(x)
	a = x
	print("this is New set_a a=", a)
end

function mod.new_fn_get_a()
	print("mod.new_fn_get_a a=", a or "nil")
	return a
end

-- local debug = require "debug"
mod.getinfo = debug.getinfo

local meta = {}
meta.__index = meta

function meta:show()
	print("this is mod show NEW")
end

function mod.new()
	return setmetatable({}, meta)
end

return mod

