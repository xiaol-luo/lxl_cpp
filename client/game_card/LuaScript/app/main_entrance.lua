
--  -require_files app/main_entrance -execute_fns setup_lua_logics

---@type LuaApp
g_ins = nil

function error_handler(error_msg)
    error_msg = debug.traceback(error_msg)
    log_error(error_msg)
end

function setup_lua_logics(arg)
    Functional.error_handler = error_handler
    local server_lua_script_dir = path.combine(CS.UnityEngine.Application.dataPath, "../LuaScriptServer")
    log_print("server_lua_script_dir ", server_lua_script_dir)
    ParseArgs.append_lua_search_path("../LuaScript")
    ParseArgs.append_lua_search_path("../LuaScriptServer")
    require("app.app_impl.lua_app")
    g_ins = LuaApp:new()
    g_ins:init(arg)
    g_ins:start()
end

function on_native_drive_update()
    if g_ins then
        -- print("reach on_native_drive_update")
        g_ins:update()
--[[
        CS.Lua.HttpClient.Get("https://g100.gdl.netease.com/game_config_list.json", function(...)
            log_print("11111111111111111111111111111111111111111", ...)
        end)
    end
    ]]
end

function release_lua_logics()
    g_ins:stop()
    g_ins:release()
    g_ins = nil
end



