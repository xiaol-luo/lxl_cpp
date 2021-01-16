
print("reach hotfix_logic start")

-- hotfix_file("main_logic", _G)
-- hotfix_file("role.role_mgr", _G)
-- hotfix_file("role.role", _G)
-- require("main_logic")
-- require("role.role")

for _, v in pairs(require("app.app_impl.lua_app_pre_require_server_files")) do
    local files =  collect_batch_require_files({ { includes = { v } } })
    for _, elem in ipairs(files) do
        hotfix_file(elem)
        -- print("hotfix file ", elem)
    end
end

do
    local files = collect_batch_require_files({ { includes = { "app.include" } } } )
    for _, elem in ipairs(files) do
        hotfix_file(elem)
        -- print("hotfix file ", elem)
    end
end

print("reach hotfix_logic end")
