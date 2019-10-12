mod = mod or class("mod")

local a = 10
local b = 20

g_var = 80
g_var2 = 200


local function foobar()
	print("new function foobar a=", a)
	return a
end

function mod.foobar2()
		print("new function foobar2222222 a=", a)
		return a
	end

function mod.get_fn()
	print("new function get_fn")
	return mod.foobar2
end


function mod.print_vars()
	print("new fn print_vars a=", a)
	print("old fn print_vars, b=", b)
	print("new fn print_vars, g_var=", g_var)
	print("new fn print_vars, g_var=", g_var2)
end

function mod:ctor()
	self.xx = 200
end

function mod:print_xxx()
	print("new mod xxx", self.xx)
end