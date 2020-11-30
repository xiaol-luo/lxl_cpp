

batch_require(require("servers.entrance.pre_require_files"))
batch_require(require("servers.entrance.common_require_files"))

-- importance global vars
---@type GameServerBase
SERVER_INS = nil
PROTO_PARSER = nil

local opt_op_fn_map = {
    [Const.main_args_server] = ParseArgs.make_closure(ParseArgs.fill_one_arg, Const.main_args_server),
    [Const.main_args_data_dir] = ParseArgs.make_closure(ParseArgs.fill_one_arg, Const.main_args_data_dir),
    [Const.main_args_config_file] = ParseArgs.make_closure(ParseArgs.fill_one_arg, Const.main_args_config_file),
    [Const.main_args_logic_param] = ParseArgs.make_closure(ParseArgs.fill_args, Const.main_args_logic_param),
}

function start_script(main_args)
    local init_args = ParseArgs.parse_main_args(main_args, ParseArgs.setup_parse_fns(opt_op_fn_map))
    local server_name = init_args[Const.main_args_server]
    local setting_file = path.combine(init_args[Const.main_args_data_dir], init_args[Const.main_args_config_file])
    local init_setting = xml.parse_file(setting_file)
    
    -- xml.print_table(init_setting)

    init_setting = init_setting["root"]

    local logic_main_file = string.format("servers.server_impl.%s.server_main", server_name)
    require(logic_main_file)
    SERVER_INS = create_server_main(init_setting, init_args)
    if not SERVER_INS:init() then
        SERVER_INS = nil
        log_error("SERVER_INS:init fail")
        native.try_quit_game()
        return
    end
    SERVER_INS:start()
end

-- callback from native
function OnNotifyQuitGame()
    log_debug("lua OnNotifyQuitGame")
    if SERVER_INS then
        SERVER_INS:notify_quit_game()
    end
end

-- callback from native
function CheckCanQuitGame()
    -- log_debug("lua CheckCanQuitGame")
    if SERVER_INS then
        return SERVER_INS:check_can_quit_game()
    end
    return true
end

-- start_script()