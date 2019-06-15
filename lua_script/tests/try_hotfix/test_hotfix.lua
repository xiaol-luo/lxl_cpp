
local search_path = path.combine(arg[4], "tests/try_hotfix")
ParseArgs.append_lua_search_path(search_path)

local mymod = require("mymod")

print("show mymod", mymod)



local a = 1
local b = 2

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
-- reload.reload { "mymod" }

print("after hotfix")
safe_call(fn)

