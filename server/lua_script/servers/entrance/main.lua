
-- importance global vars
MAIN_ARGS = nil
SERVER_SETTING = nil
SERVER_MAIN = nil
PROTO_PARSER = nil

local opt_op_fn_map = {
    [const.main_args_server] = ParseArgs.make_closure(ParseArgs.fill_one_arg, const.main_args_server),
    [const.main_args_data_dir] = ParseArgs.make_closure(ParseArgs.fill_one_arg, const.main_args_data_dir),
    [const.main_args_config_file] = ParseArgs.make_closure(ParseArgs.fill_one_arg, const.main_args_config_file),
    [const.main_args_logic_param] = ParseArgs.make_closure(ParseArgs.fill_args, const.main_args_logic_param),
}

function start_script(main_args)
    MAIN_ARGS = ParseArgs.parse_main_args(main_args, ParseArgs.setup_parse_fns(opt_op_fn_map))
    local server_name = MAIN_ARGS[const.main_args_server]
    local setting_file = path.combine(MAIN_ARGS[const.main_args_data_dir], MAIN_ARGS[const.main_args_config_file])
    SERVER_SETTING = xml.parse_file(setting_file)
    xml.print_table(SERVER_SETTING)
    SERVER_SETTING = SERVER_SETTING["root"]

    local logic_main_file = string.format("servers.server_impl.%s.server_main", server_name)
    require(logic_main_file)
    SERVER_MAIN = create_server_main()
    SERVER_MAIN:init()
    SERVER_MAIN:start()
end

-- callback from native
function OnNotifyQuitGame()
    log_debug("lua OnNotifyQuitGame")
    if SERVER_MAIN then
        SERVER_MAIN:OnNotifyQuitGame()
    end
end

-- callback from native
function CheckCanQuitGame()
    -- log_debug("lua CheckCanQuitGame")
    if SERVER_MAIN then
        return SERVER_MAIN:CheckCanQuitGame()
    end
    return true
end

-- start_script()