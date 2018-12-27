
require("util.util")
-- util.append_lua_search_path("./libs")
-- util.append_c_search_path("./dyn_libs")

local print_r = require("sproto.print_r")

print("before parse")
print("package.cpath:")
print(package.cpath)
print("package.path:")
print(package.path)

print("arg:")
print_r(arg)
ret = util.parse_main_args(arg)
util.use_parse_main_ret(ret)

print("ret:")
print_r(ret)

local serpent = require("libs.lua_protobuf.serpent")
print(serpent.block(ret))
print(serpent.line(ret))



print()
print("after parse")
print("package.cpath:")
print(package.cpath)
print("package.path:")
print(package.path)