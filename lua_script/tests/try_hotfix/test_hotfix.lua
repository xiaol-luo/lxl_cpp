
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

local hotfix_chunk_str = "mod = mod\n g_var2=200\n g_var = 800\n local b = 1000\n local a=10000\n mod.print_vars = function() print('new vars', a or 'nil', b, g_var, g_var2) end\n"
require("mymod")

if false then
	mod.print_vars()
	print("g_var2=", g_var2)
	local env = {}
	setmetatable(env, {
		__index = _G,
		__newindex = function(self, k, v)
			print("__newindex", k, tostring(v))
			if nil == v then
				rawset(self, k, v)
				print("__newindex 1", k, tostring(v))
				return
			end
			if "table" ~= type(v) then
				print("__newindex 2", k, tostring(v))
				rawset(self, k, v)
				return
			end
			local local_v = rawget(self, k)
			if local_v == v then
				print("__newindex 3", k, tostring(v))
				return
			end
			if not local_v then
				print("__newindex 4", k, tostring(v))
				local_v = {}
				setmetatable(local_v, {__index = v})
				rawset(self, k, local_v)
				return
			end
			print("__newindex 5", k, tostring(v))
		end
	})

	print("mod", tostring(mod))
	local f, error_msg = load(hotfix_chunk_str)
	assert(f, error_msg)
	debug.setupvalue(f, 1, env)
	local ok, error_msg = pcall(f)
	assert(ok, error_msg)

	print("mod", tostring(env.mod))

	print("g_var2=", g_var2)

	local opt = {
		replace_fn = true,
		replace_var = false,
	}
	print("env is ", env)
	hotfix_table(_G, env, opt, {})

	mod.print_vars()
	mod.get_fn()
	env.mod.print_vars()
	env.mod.get_fn()
else
	mod.print_vars()
	print("---------------------------------- before hotfix_file ------------------------------------------- ")
	hotfix_file("mymod_update", _G)
	print("---------------------------------- after hotfix_file ------------------------------------------- ")
	mod.print_vars()
end

