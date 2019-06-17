mod = mod or {}

local a = 10
local b = 20

g_var = 80
g_var2 = 200

local function foobar()
	print("new function foobar")
	return a
end

function mod.get_fn()
	print("new function get_fn")
	return foobar
end

function mod.print_vars()
	print("new fn print_vars a=", a)
	print("old fn print_vars, b=", b)
	print("new fn print_vars, g_var=", g_var)
end
