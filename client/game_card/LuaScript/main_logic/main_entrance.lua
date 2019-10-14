
--  -require_files main_logic/main_entrance -execute_fns setup_lua_logics

function setup_lua_logics(arg)
    ParseArgs.append_lua_search_path("main_logic")
    require("main_logic")
    g_ins = MainLogic:new()
    g_ins:init()
end

function on_native_drive_update()
    -- print("reach on_native_drive_update")
    g_ins:on_frame()
end



