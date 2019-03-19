

function append_lua_search_path(v)
    package.path = string.format("%s;%s/?.lua;%s/?/init.lua", package.path, v, v)
end

function append_c_search_path(v)
    package.cpath = string.format("%s;%s/?.dll;", package.cpath, v)
end

ParseArgs = ParseArgs or {}
ParseArgs.One_Gang = "-"
ParseArgs.Opt_Lua_Path = "lua_path"
ParseArgs.Opt_C_Path = "c_path"

function ParseArgs.make_opt(opt_name)
    return ParseArgs.One_Gang .. opt_name
end

function ParseArgs.fill_one_arg(args, arg_idx, ret, opt_name)

end

function ParseArgs.fill_args(args, arg_idx, ret, opt_name)

end

function ParseArgs.setup_parse_fns(opt_fn_map, ret_fns)
    ret_fns = ret_fns or {}
    
    return ret_fns
end

local opt_lua_path = "lua_path"
local opt_c_path = "c_path"

MAIN_ARGS_SERVICE = "service"
MAIN_ARGS_LOGIC_PARAM = "logic_param"
MAIN_ARGS_DATA_DIR = "data_dir"

function ParseArgs.parse_main_args(input_args, out_ret)
    local fn_is_cmd_prefix = function(s)
        local ret = string.match(s, ParseArgs.One_Gang .. "%S+")
        -- print(string.format("parse_main_args %s %s", s, string.match(s, ParseArgs.One_Gang .. "%S+" )))
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
    parse_fns[ParseArgs.One_Gang .. opt_lua_path] = function(args, arg_idx, ret)
        return fn_fill_args(args, arg_idx, ret, opt_lua_path)
    end
    parse_fns[ParseArgs.One_Gang .. opt_c_path] = function(args, arg_idx, ret)
        return fn_fill_args(args, arg_idx, ret, opt_c_path)
    end
    parse_fns[ParseArgs.One_Gang .. MAIN_ARGS_SERVICE] = function(args, arg_idx, ret)
        return fn_fill_one_args(args, arg_idx, ret, MAIN_ARGS_SERVICE)
    end
    parse_fns[ParseArgs.One_Gang .. MAIN_ARGS_LOGIC_PARAM] = function(args, arg_idx, ret)
        return fn_fill_args(args, arg_idx, ret, MAIN_ARGS_LOGIC_PARAM)
    end
    parse_fns[ParseArgs.One_Gang .. MAIN_ARGS_DATA_DIR] = function(args, arg_idx, ret)
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
