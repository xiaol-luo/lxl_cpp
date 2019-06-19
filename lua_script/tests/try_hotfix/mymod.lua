mod = mod or class("mod")

local a = 1


g_var = 8

local function foobar()
	print("old function foobar a=", a)
	return a
end








function mod.get_fn()
	print("old function get_fn")
	return foobar
end

function mod.print_vars()
	print("old fn print_vars a=", a)
	print("old fn print_vars, g_var=", g_var)
end




function mod:ctor()
	self.xx = 100
end

function mod:print_xxx()
	print("old mod xxx", self.xx)
end
