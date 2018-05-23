print("xxx")
local lib = require("tryuselualib") 
lib.log_msg()

-- func = package.loadlib("tryuselualib", "luaopen_tryuselualib")
-- print(func)
-- func()


local t = {}

print(package.cpath)
print(package.path)

for k, v in pairs(t) do
    print(k, v) 
end