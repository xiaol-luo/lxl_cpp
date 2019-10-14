
print("reach hotfix_logic start")

-- hotfix_file("main_logic", _G)
-- hotfix_file("role.role_mgr", _G)
-- hotfix_file("role.role", _G)
-- require("main_logic")
-- require("role.role")


batch_hotfix_files({
    "main_logic",
    "role.role_mgr",
    "role.role",
}, _G)


hotfix_require("item.item")

print("reach hotfix_logic end")
