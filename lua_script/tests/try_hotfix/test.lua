
local search_path = path.combine(arg[4], "tests/try_hotfix")
ParseArgs.append_lua_search_path(search_path)

new_print = print
-- print = old_print

local reload = require "libs.reload"
reload.postfix = "_update"	-- for test

local mymod = require "mymod"

function reload.print(...)
	local n, tb = Functional.varlen_param_info(...)
	local msg = "==== "
	for i=1, n do
		local v = tb[i]
		if i <= 1 then
			msg = msg .. tostring(v)
		else
			msg = msg .. ",  " .. tostring(v)
		end
	end
	native.log_debug(msg)
end

mymod.foobar(42)

local tmp = {}
local foo = mymod.foo2()
tmp[foo] = foo
print("FOO before", foo)

local obj = mymod.new()

obj:show()

function test()
	print("BEFORE update foo", foo)
	reload.reload { "mymod" }
	print("AFTER update foo", foo)
end

test()

foo()

print("FOO after", foo)
assert(tmp[foo] == foo)

obj:show()

print = old_print