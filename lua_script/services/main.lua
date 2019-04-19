
-- importance global vars
MAIN_ARGS = nil
SERVICE_SETTING = nil
ZONE_SETTING = nil
SERVICE_MAIN = nil
PROTO_PARSER = nil

local opt_op_fn_map = {
    [MAIN_ARGS_SERVICE_FULL_NAME] = ParseArgs.make_closure(ParseArgs.fill_one_arg, MAIN_ARGS_SERVICE_FULL_NAME),
    [MAIN_ARGS_DATA_DIR] = ParseArgs.make_closure(ParseArgs.fill_one_arg, MAIN_ARGS_DATA_DIR),
    [MAIN_ARGS_LOGIC_PARAM] = ParseArgs.make_closure(ParseArgs.fill_args, MAIN_ARGS_LOGIC_PARAM),
}

function start_script(main_args)
    MAIN_ARGS = ParseArgs.parse_main_args(main_args, ParseArgs.setup_parse_fns(opt_op_fn_map))
    local service_full_name = MAIN_ARGS[MAIN_ARGS_SERVICE_FULL_NAME]
    local service_name = native.extract_service_name(service_full_name)
    MAIN_ARGS[MAIN_ARGS_SERVICE_NAME] = service_name
    MAIN_ARGS[MAIN_ARGS_SERVICE_IDX] = native.extract_service_idx(service_full_name)
    local setting_file = path.combine(MAIN_ARGS[MAIN_ARGS_DATA_DIR], "setting", string.format("%s.xml", service_name))
    SERVICE_SETTING = xml.parse_file(setting_file)
    -- xml.print_table(SERVICE_SETTING)
    local all_setting_file = path.combine(MAIN_ARGS[MAIN_ARGS_DATA_DIR], "setting", "zone_services.xml")
    ZONE_SETTING = xml.parse_file(all_setting_file)
    -- xml.print_table(ZONE_SETTING )

    local SCC = Service_Cfg_Const
    MAIN_ARGS[MAIN_ARGS_ZONE_NAME] = ZONE_SETTING[SCC.Root][SCC.Etcd][SCC.Etcd_Root_Dir]
    -- log_debug(logic_main_file)

    PROTO_PARSER = ProtoParser:new()
    local proto_dir = path.combine(MAIN_ARGS[MAIN_ARGS_DATA_DIR], "proto")
    -- log_debug(proto_dir)
    PROTO_PARSER:add_search_dirs({ proto_dir })
    local proto_files = {} -- Todo: set this table by config
    local pid_proto_map = {} -- Todo: set this table by config
    local init_ret = PROTO_PARSER:init(proto_files, pid_proto_map)
    assert(init_ret, string.format("PROTO_PARSER:init %s", init_ret))

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