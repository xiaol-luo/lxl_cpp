
bin.exe service_name work_dir data_dir config_file lua_dir (-native_logic_param)other_params \
--lua_args_begin-- -lua_path lua_search_path -c_path lua_c_search_path -require_files lua_files  -execute_fns lua_fns

#example
bin.exe avatar ../avatar_0 ../Debug/root/datas setting/avatar_0.xml ../Debug/root/lua_script --lua_args_begin-- -lua_path . -c_path . ../Debug -require_files services.main  -execute_fns start_script

bin.exe avatar ../avatar_0 ../Debug/root/datas setting/avatar_0.xml ../Debug/root/lua_script --lua_args_begin-- -lua_path . -c_path . ../Debug -require_files services.main  -execute_fns start_script