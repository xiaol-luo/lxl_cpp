
print("reach hotfix_logic start")

-- hotfix_file("main_logic", _G)
-- hotfix_file("role.role_mgr", _G)
-- hotfix_file("role.role", _G)
-- require("main_logic")
-- require("role.role")

for _, v in pairs(require("app.app_impl.lua_app_pre_require_server_files")) do
    batch_hotfix_files(collect_batch_require_files(v))
end

local hotfix_files = require("app.app_impl.lua_app_pre_require_files")
batch_hotfix_files(hotfix_files)

print("reach hotfix_logic end")
