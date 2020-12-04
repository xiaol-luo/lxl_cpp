lua_auto_include ..\..\LuaScript\libs --suffix .lua 
lua_auto_include ..\..\LuaScript\common --suffix .lua
lua_auto_include ..\..\LuaScript\app --suffix .lua --exclude_files main_entrance.lua lua_app_pre_require_files.lua lua_app_pre_require_server_files.lua lua_app.lua ui_panel_setting.lua --exclude_dirs hotfix