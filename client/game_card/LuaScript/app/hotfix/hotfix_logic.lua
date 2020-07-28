
print("reach hotfix_logic start")

-- hotfix_file("main_logic", _G)
-- hotfix_file("role.role_mgr", _G)
-- hotfix_file("role.role", _G)
-- require("main_logic")
-- require("role.role")


local hotfix_files = require("main_logic.main_logic_impl.pre_require_files")
batch_hotfix_files(hotfix_files, _G)

print("reach hotfix_logic end")
