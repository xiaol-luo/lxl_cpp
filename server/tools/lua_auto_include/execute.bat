python lua_auto_include.py ..\..\lua_script\libs --suffix .lua
python lua_auto_include.py ..\..\lua_script\common --suffix .lua
python lua_auto_include.py ..\..\lua_script\servers\common --suffix .lua
python lua_auto_include.py ..\..\lua_script\servers\services --suffix .lua

python lua_auto_include.py ..\..\lua_script\servers\server_impl\auth --suffix .lua --exclude_files server_main.lua
python lua_auto_include.py ..\..\lua_script\servers\server_impl\create_role --suffix .lua --exclude_files server_main.lua
python lua_auto_include.py ..\..\lua_script\servers\server_impl\fight --suffix .lua --exclude_files server_main.lua

python lua_auto_include.py ..\..\lua_script\servers\server_impl\game --suffix .lua --exclude_files server_main.lua
python lua_auto_include.py ..\..\lua_script\servers\server_impl\game --suffix .lua --exclude_files server_main.lua

python lua_auto_include.py ..\..\lua_script\servers\server_impl\gate --suffix .lua --exclude_files server_main.lua
python lua_auto_include.py ..\..\lua_script\servers\server_impl\login --suffix .lua --exclude_files server_main.lua
python lua_auto_include.py ..\..\lua_script\servers\server_impl\match --suffix .lua --exclude_files server_main.lua
python lua_auto_include.py ..\..\lua_script\servers\server_impl\platform --suffix .lua --exclude_files server_main.lua
python lua_auto_include.py ..\..\lua_script\servers\server_impl\room --suffix .lua --exclude_files server_main.lua
python lua_auto_include.py ..\..\lua_script\servers\server_impl\world --suffix .lua --exclude_files server_main.lua
python lua_auto_include.py ..\..\lua_script\servers\server_impl\world_sentinel --suffix .lua --exclude_files server_main.lua
