../test_listen ../Debug/root/lua_script/main.lua -lua_path E:/ws/lxl_cpp/Debug/root/lua_script -c_path E:/ws/lxl_cpp/Debug -data_dir E:/ws/lxl_cpp/Debug/root/datas -service test_listen -logic_param 1 -work_dir E:/ws/try_cmake/lxl_cpp/Debug/ws

# new format
bin.exe service_name work_dir data_dir lua_dir (-native_logic_param)other_params \
--lua_args_begin-- -lua_path lua_search_path -c_path lua_c_search_path -data_dir data_dir_detail -logic_param logic_param_detail

#example
bin.exe avatar.0 ../avatar_0 ../Debug/root/datas ../Debug/root/lua_script --lua_args_begin-- -lua_path . -c_path . ../Debug -require_files services.main  -execute_fns start_script