
--  -require_files main_logic/main_entrance -execute_fns setup_lua_logics

function error_handler(error_msg)
    error_msg = debug.traceback(error_msg)
    log_error(error_msg)
end

function setup_lua_logics(arg)
    print("setup_lua_logics ", arg)
    Functional.error_handler = error_handler
    ParseArgs.append_lua_search_path("main_logic")
    require("main_logic_impl.fake_main_logic")
    g_ins = MainLogic:new()
    g_ins:init(arg)
    g_ins:on_start()
end

function on_native_drive_update()
    -- print("reach on_native_drive_update")
    g_ins:on_update()
end



