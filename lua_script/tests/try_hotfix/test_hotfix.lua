
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

require("mymod")

local a = mod:new()
local foo_fn = mod.get_fn()
foo_fn()

a:print_xxx()
mod.print_vars()
print("---------------------------------- before hotfix_file ------------------------------------------- ")
hotfix_file("mymod_update", _G)
print("---------------------------------- after hotfix_file ------------------------------------------- ")
mod.print_vars()
a:print_xxx()

a = mod:new()
a:print_xxx()
foo_fn()
mod.get_fn()()