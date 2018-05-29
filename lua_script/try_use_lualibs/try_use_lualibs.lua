print("xxx")
local lib, other_lib = require("tryuselualib") 
lib, other_lib = require("tryuselualib") 
lib, other_lib = require("tryuselualib") 
lib.log_msg()
-- other_lib.log_msg() -- other_lib is nil
tryuselualib.log_msg()
othertryuselualib.log_msg()

-- func = package.loadlib("tryuselualib", "luaopen_tryuselualib")
-- print(func)
-- func()

print("package.cpath:")
print(package.cpath)
print("package.path:")
print(package.path)

print("End")
