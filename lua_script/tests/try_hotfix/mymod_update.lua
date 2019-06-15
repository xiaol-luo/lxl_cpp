
local mod = {}

local a
local b
--local a = 5
-- g_var = 2
local g_fn = function() end
local g_fn_not_for_mod = function() end

mod.mod_g_var = g_var
mod.mod_g_fn = g_fn

local function foobar()
	print("this is new foobar")
	return a
end

function mod.get_fn()
	-- print(b)
	-- print(g_var)
	-- print(mod.mod_g_fn)
	return foobar
end

function mod.set_a(x)
	a = x
	print("this is New set_a a=", a)
end

--[[
function mod.new_fn_get_a()
	print("mod.new_fn_get_a a=", a or "nil")
	return a
end

function mod.new_fn_get_fn()
	print("mod.new_fn_get_fn foobar=", foobar or "nil")
	return foobar
end
--]]

local debug = require "debug"
mod.mod_getinfo = debug.getinfo

local meta = {}
meta.__index = meta

function meta:show()
	print("this is mod show NEW, a=", a)
	-- print("g_var is ", g_var)
end

function mod.new()
	return setmetatable({}, meta)
end

return mod

