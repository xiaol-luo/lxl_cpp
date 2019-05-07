
-- importance global vars
MAIN_ARGS = nil
SERVICE_SETTING = nil
SERVICE_MAIN = nil
PROTO_PARSER = nil

local opt_op_fn_map = {
    [MAIN_ARGS_SERVICE] = ParseArgs.make_closure(ParseArgs.fill_one_arg, MAIN_ARGS_SERVICE),
    [MAIN_ARGS_DATA_DIR] = ParseArgs.make_closure(ParseArgs.fill_one_arg, MAIN_ARGS_DATA_DIR),
    [MAIN_ARGS_CONFIG_FILE] = ParseArgs.make_closure(ParseArgs.fill_one_arg, MAIN_ARGS_CONFIG_FILE),
    [MAIN_ARGS_LOGIC_PARAM] = ParseArgs.make_closure(ParseArgs.fill_args, MAIN_ARGS_LOGIC_PARAM),
}

function start_script(main_args)
    MAIN_ARGS = ParseArgs.parse_main_args(main_args, ParseArgs.setup_parse_fns(opt_op_fn_map))
    local service_name = MAIN_ARGS[MAIN_ARGS_SERVICE]
    local setting_file = path.combine(MAIN_ARGS[MAIN_ARGS_DATA_DIR], MAIN_ARGS[MAIN_ARGS_CONFIG_FILE])
    SERVICE_SETTING = xml.parse_file(setting_file)
    xml.print_table(SERVICE_SETTING)
    SERVICE_SETTING = SERVICE_SETTING[Service_Const.Root]

    local logic_main_file = string.format("services.%s.service_main", service_name)
    require(logic_main_file)
    SERVICE_MAIN = create_service_main()
    SERVICE_MAIN:init()
    SERVICE_MAIN:start()
end

-- callback from native
function OnNotifyQuitGame()
    log_debug("lua OnNotifyQuitGame")
    if SERVICE_MAIN then
        SERVICE_MAIN:OnNotifyQuitGame()
    end
end

-- callback from native
function CheckCanQuitGame()
    log_debug("lua CheckCanQuitGame")
    if SERVICE_MAIN then
        return SERVICE_MAIN:CheckCanQuitGame()
    end
    return true
end

-- start_script()