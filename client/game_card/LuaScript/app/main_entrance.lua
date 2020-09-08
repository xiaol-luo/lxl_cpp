
--  -require_files app/main_entrance -execute_fns setup_lua_logics

---@type LuaApp
g_ins = nil

function batch_require(input_arg, dir_path)
    if "table" == type(input_arg) then
        for _, v in pairs(input_arg) do
            if "table" == type(v) then
                local new_dir_path = nil
                if dir_path then
                    new_dir_path = dir_path
                    if v.dir then
                        new_dir_path = string.format("%s.%s", dir_path, v.dir)
                    end
                else
                    new_dir_path = v.dir
                end
                batch_require(v.files, new_dir_path)
            else
                local file_path = v
                if dir_path then
                    file_path = string.format("%s.%s", dir_path, file_path)
                end
                require(file_path)
            end
        end
    else
        local file_path = input_arg
        if dir_path then
            file_path = string.format("%s.%s", dir_path, file_path)
        end
        require(file_path)
    end
end

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

        --UnityHttpClient.get("http://127.0.0.1:30002/login_platform?platform_account_id=12345&game_id=2234&password=12345", function(...)
        --        log_print("11111111111111111111111111111111111111111", ...)
        --    end, { a="111", b="ccc" })

    end
end

function release_lua_logics()
    g_ins:stop()
    g_ins:release()
    g_ins = nil
end



