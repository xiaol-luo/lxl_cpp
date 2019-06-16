
local search_path = path.combine(arg[4], "tests/try_hotfix")
ParseArgs.append_lua_search_path(search_path)

function print_upvalues(f, pre_tag)
	local idx = 0
	while true do
		idx = idx + 1
		local k, v = debug.getupvalue(f, idx)
		if not k then
			break
		end
		print(pre_tag, k, tostring(v))
	end
end

local a = 11
local b = 21
local d = 201

function old_fn()
	print("old a is", a)
end
function new_fn()
	print("new a is", a)
	print("new b is", b)
	print("1234566")
end
local fn = old_fn
fn()
hotfix_function(old_fn, new_fn)
print("after hotfix")
fn()


local repalce_print_c = "repalce_print_c"
print("test hotfix module function \n\n\n")
local replace_print_a = function(self)
	print("replace_print_a", a)
end
local replace_print_c = function(self)
	print("repalce_print_c a=", a)
	print("repalce_print_c =", repalce_print_c)
	print("repalce_print_c d=", d)
end
local mymod = require("mymod")
mymod.print_a()
print("mod.print_c = ", mymod.print_c)
mymod.print_c = function()
	print("use this to hold place")
end
hotfix_function(mymod.print_a, replace_print_a, mymod)
hotfix_function(mymod.print_c, replace_print_c, mymod)
print("------------ after replace print_a")
mymod.print_a()
mymod.print_c()

print(mymod)
