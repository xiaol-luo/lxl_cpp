
local search_path = path.combine(arg[4], "tests/try_hotfix")
ParseArgs.append_lua_search_path(search_path)

local reload = require "libs.reload"
reload.postfix = "_update"	-- for test

function reload.print(...)
	local n, tb = Functional.varlen_param_info(...)
	local msg = "==== "
	for i=1, n do
		local v = tostring(tb[i])
		if i <= 1 then
			msg = msg .. v
		else
			msg = msg .. ",  " .. v
		end
	end
	native.log_debug(msg)
end

local mymod = require "mymod"

local foo = mymod.get_fn()
local tmp = {}
tmp[foo] = foo

local obj = mymod.new()

obj:show()
mymod.set_a(2)
print("BEFORE reload foo fn is", foo)
print("BEFORE reload foo() is ", foo())
native.log_debug(string.format("BEFORE reload mod.getinfo is %s", mymod.getinfo))

print("================================================================")

reload.reload { "mymod" }

print("================================================================")

obj:show()
mymod.set_a(3)
print("AFTER reload foo fn is", foo)
print("AFTER reload foo() is ", foo())
native.log_debug(string.format("AFTER reload mod.getinfo is %s", mymod.getinfo))
-- print("AFTER reload  mod.new_fn_get_a() is ", mymod.new_fn_get_a() or "nil")
-- print("AFTER reload  mod.new_fn_get_fn() is ", mymod.new_fn_get_fn() or "nil")

assert(tmp[foo] == foo)

