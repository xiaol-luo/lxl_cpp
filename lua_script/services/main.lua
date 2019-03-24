
function OnNotifyQuitGame()
    log_debug("lua OnNotifyQuitGame")
    if ServiceMain and ServiceMain.OnNotifyQuitGame then
        ServiceMain.OnNotifyQuitGame()
    end
end

function CheckCanQuitGame()
    log_debug("lua CheckCanQuitGame")
    if ServiceMain and ServiceMain.CheckCanQuitGame then
        return ServiceMain.CheckCanQuitGame()
    end
    return true
end


MAIN_ARGS = nil
SERVICE_SETTING = nil
ALL_SERVICE_SETTING = nil

MAIN_ARGS_SERVICE = "service"
MAIN_ARGS_SERVICE_NAME = "service_name"
MAIN_ARGS_SERVICE_ID = "service_id"
MAIN_ARGS_DATA_DIR = "data_dir"
MAIN_ARGS_LOGIC_PARAM = "logic_param"
local opt_op_fn_map = {
    [MAIN_ARGS_SERVICE] = ParseArgs.make_closure(ParseArgs.fill_one_arg, MAIN_ARGS_SERVICE),
    [MAIN_ARGS_DATA_DIR] = ParseArgs.make_closure(ParseArgs.fill_one_arg, MAIN_ARGS_DATA_DIR),
    [MAIN_ARGS_LOGIC_PARAM] = ParseArgs.make_closure(ParseArgs.fill_args, MAIN_ARGS_LOGIC_PARAM),
}

function start_script(main_args)
    MAIN_ARGS = ParseArgs.parse_main_args(main_args, ParseArgs.setup_parse_fns(opt_op_fn_map))
    local service_full_name = MAIN_ARGS[MAIN_ARGS_SERVICE]
    local service_name = native.extract_service_name(service_full_name)
    MAIN_ARGS[MAIN_ARGS_SERVICE_NAME] = service_name
    MAIN_ARGS[MAIN_ARGS_SERVICE_ID] = native.extract_service_id(service_full_name)
    local setting_file = path.combine(MAIN_ARGS[MAIN_ARGS_DATA_DIR], "setting", string.format("%s.xml", service_name))
    SERVICE_SETTING = xml.parse_file(setting_file)
    -- xml.print_table(SERVICE_SETTING)
    local all_setting_file = path.combine(MAIN_ARGS[MAIN_ARGS_DATA_DIR], "setting", "all_services.xml")
    ALL_SERVICE_SETTING = xml.parse_file(all_setting_file)
    xml.print_table(ALL_SERVICE_SETTING )
    local logic_main_file = string.format("services.%s.service_main", service_name)
    -- log_debug(logic_main_file)
    require(logic_main_file)
    ServiceMain.start()
end

-- start_script()