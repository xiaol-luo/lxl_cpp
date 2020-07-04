
batch_require(require("robots.entrance.pre_require_files"))
batch_require(require("robots.entrance.common_require_files"))

-- importance global vars
ROBOT_INS = nil

Arg_Name = {}
Arg_Name.robot = "server"
Arg_Name.data_dir = "data_dir"
Arg_Name.config_file = "config_file"
Arg_Name.logic_param = "logic_param"

local opt_op_fn_map = {
    [Arg_Name.robot] = ParseArgs.make_closure(ParseArgs.fill_one_arg, Arg_Name.robot),
    [Arg_Name.data_dir] = ParseArgs.make_closure(ParseArgs.fill_one_arg, Arg_Name.data_dir),
    [Arg_Name.config_file] = ParseArgs.make_closure(ParseArgs.fill_one_arg, Arg_Name.config_file),
    [Arg_Name.logic_param] = ParseArgs.make_closure(ParseArgs.fill_args, Arg_Name.logic_param),
}

function start_script(main_args)
    log_print("main_args", main_args)
    local init_args = ParseArgs.parse_main_args(main_args, ParseArgs.setup_parse_fns(opt_op_fn_map))
    local robot_name = init_args[Arg_Name.robot]
    local setting_file = path.combine(init_args[Arg_Name.data_dir], init_args[Arg_Name.config_file])
    local init_setting = xml.parse_file(setting_file)
    
    xml.print_table(init_setting)

    init_setting = init_setting["root"]

    local logic_main_file = string.format("robots.robot_impl.%s.robot_main", robot_name)
    require(logic_main_file)
    ROBOT_INS = create_robot_main(init_setting, init_args)
    if not ROBOT_INS:init() then
        ROBOT_INS = nil
        log_error("ROBOT_INS:init fail")
        native.try_quit_game()
        return
    end
    ROBOT_INS:start()
end

-- callback from native
function OnNotifyQuitGame()
    log_debug("lua OnNotifyQuit")
    if ROBOT_INS then
        ROBOT_INS:notify_quit()
    end
end

-- callback from native
function CheckCanQuitGame()
    -- log_debug("lua CheckCanQuitGame")
    if ROBOT_INS then
        return ROBOT_INS:check_can_quit()
    end
    return true
end