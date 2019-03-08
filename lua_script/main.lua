
util = util or {}
local c_one_gang = "-"
local opt_lua_path = "lua_path"
local opt_c_path = "c_path"
MAIN_ARGS_SERVICE = "service"
MAIN_ARGS_LOGIC_PARAM = "logic_param"
MAIN_ARGS_DATA_DIR = "data_dir"


function util.parse_main_args(input_args, out_ret)
    local fn_is_cmd_prefix = function(s)
        local ret = string.match(s, c_one_gang .. "%S+")
        -- print(string.format("parse_main_args %s %s", s, string.match(s, c_one_gang .. "%S+" )))
        return ret
    end
    local fn_fill_args = function (args, arg_idx, ret, opt_name)
        ret[opt_name] = ret[opt_name] or {}
        local t = ret[opt_name]
        local idx = arg_idx
        while idx <= #args do
            local val = args[idx]
            if fn_is_cmd_prefix(val) then
                -- print(string.format("break %s %s %s",  "fn_fill_args ", opt_name, val))
                break
            end
            -- print(string.format("%s %s %s",  "fn_fill_args ", opt_name, val))
            table.insert(t, val)
            idx = idx + 1
        end
        return idx - arg_idx
    end
    local fn_fill_one_args = function(args, arg_idx, ret, opt_name)
        local consume_idx = fn_fill_args(args, arg_idx, ret, opt_name)
        if ret[opt_name] and #ret[opt_name] > 0 then
            ret[opt_name] = ret[opt_name][1]
        else
            ret[opt_name] = nil
        end
        return consume_idx
    end
    local parse_fns = {}
    parse_fns[c_one_gang .. opt_lua_path] = function(args, arg_idx, ret)
        return fn_fill_args(args, arg_idx, ret, opt_lua_path)
    end
    parse_fns[c_one_gang .. opt_c_path] = function(args, arg_idx, ret)
        return fn_fill_args(args, arg_idx, ret, opt_c_path)
    end
    parse_fns[c_one_gang .. MAIN_ARGS_SERVICE] = function(args, arg_idx, ret)
        return fn_fill_one_args(args, arg_idx, ret, MAIN_ARGS_SERVICE)
    end
    parse_fns[c_one_gang .. MAIN_ARGS_LOGIC_PARAM] = function(args, arg_idx, ret)
        return fn_fill_args(args, arg_idx, ret, MAIN_ARGS_LOGIC_PARAM)
    end
    parse_fns[c_one_gang .. MAIN_ARGS_DATA_DIR] = function(args, arg_idx, ret)
        return fn_fill_one_args(args, arg_idx, ret, MAIN_ARGS_DATA_DIR)
    end

    out_ret = out_ret or {}
    local argc = #input_args
    local all_ok = true
    local idx = 1
    while idx <= argc do
        local val = input_args[idx]
        local consume_arg_count = 0
        if fn_is_cmd_prefix(val) then
            if parse_fns[val] then
                consume_arg_count = parse_fns[val](input_args, idx + 1, out_ret)
            else
                consume_arg_count = fn_fill_args(input_args, idx + 1, out_ret, "unknown")
            end
        end
        idx = idx + 1 + consume_arg_count
    end
    return out_ret
end

function util.append_lua_search_path(v)
    package.path = string.format("%s;%s/?.lua;%s/?/init.lua", package.path, v, v)
end

function util.append_c_search_path(v)
    package.cpath = string.format("%s;%s/?.dll;", package.cpath, v)
end

local use_parse_main_ret = function(ret)
    if ret[opt_c_path] then
        for _, v in pairs(ret[opt_c_path]) do
            util.append_c_search_path(v)
        end
    end
    if ret[opt_lua_path] then
        for _, v in pairs(ret[opt_lua_path]) do
            util.append_lua_search_path(v)
        end
    end
end

local pre_require_files = function()
    local files = require("require_files")
    for _, v in ipairs(files) do
        require(v)
    end
end

local add_search_paths = function()
    for _, v in ipairs(require("lua_search_paths")) do
        util.append_lua_search_path(v)
    end
    for _, v in ipairs(require("c_search_paths")) do
        util.append_c_search_path(v)
    end
end


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
LOGIC_SETTING = nil

function start_script()
    MAIN_ARGS = util.parse_main_args(arg)
    use_parse_main_ret(MAIN_ARGS)
    add_search_paths()
    pre_require_files()
    local setting_file = path.combine(MAIN_ARGS[MAIN_ARGS_DATA_DIR], MAIN_ARGS[MAIN_ARGS_SERVICE], "setting.xml")
    LOGIC_SETTING = xml.parse_file(setting_file)
    -- xml.print_table(LOGIC_SETTING)
    local logic_main_file = string.format("services.%s.service_main", MAIN_ARGS[MAIN_ARGS_SERVICE])
    print(logic_main_file)
    require(logic_main_file)
    ServiceMain.start()
end

start_script()