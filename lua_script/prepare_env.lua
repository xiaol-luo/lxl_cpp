
ParseArgs = ParseArgs or {}
ParseArgs.One_Gang = "-"
ParseArgs.Opt_Lua_Path = "lua_path"
ParseArgs.Opt_C_Path = "c_path"
ParseArgs.Opt_Require_Files = "require_files"
ParseArgs.Opt_Execute_Fns = "execute_fns"

function ParseArgs.append_lua_search_path(v)
    package.path = string.format("%s;%s/?.lua;%s/?/init.lua", package.path, v, v)
end

function ParseArgs.append_c_search_path(v)
    package.cpath = string.format("%s;%s/?.dll;", package.cpath, v)
end

function ParseArgs.make_cmd_prefix(opt_name)
    return ParseArgs.One_Gang .. opt_name
end

function ParseArgs.is_cmd_prefix(str)
    local ret = string.match(str, ParseArgs.One_Gang .. "%S+")
    return ret
end

function ParseArgs.fill_args(opt_name, args, arg_idx, ret)
    ret[opt_name] = ret[opt_name] or {}
    local t = ret[opt_name]
    local idx = arg_idx
    while idx <= #args do
        local val = args[idx]
        if ParseArgs.is_cmd_prefix(val) then
            -- print(string.format("break %s %s %s",  "fn_fill_args ", opt_name, val))
            break
        end
        -- print(string.format("%s %s %s",  "fn_fill_args ", opt_name, val))
        table.insert(t, val)
        idx = idx + 1
    end
    return idx - arg_idx
end

function ParseArgs.fill_one_arg(opt_name, args, arg_idx, ret)
    local consume_idx = ParseArgs.fill_args(opt_name, args, arg_idx, ret)
    if ret[opt_name] and #ret[opt_name] > 0 then
        ret[opt_name] = ret[opt_name][1]
    else
        ret[opt_name] = nil
    end
    return consume_idx
end

function ParseArgs.setup_parse_fns(opt_fn_map, ret_fns)
    ret_fns = ret_fns or {}
    for opt_name, op_fn in pairs(opt_fn_map) do
        -- ret_fns[ParseArgs.make_cmd_prefix(opt_name)] = function(args, arg_idx, ret) return op_fn(args, arg_idx, ret) end
        ret_fns[ParseArgs.make_cmd_prefix(opt_name)] = op_fn
    end
    return ret_fns
end

function ParseArgs.error_handler(err_msg)
    err_msg = debug.traceback(err_msg)
    log_error(err_msg)
end

function ParseArgs.make_closure(fn, ...)
    local t = {...}
    local ret = function(...)
        local is_ok, fn_ret = xpcall(fn, ParseArgs.error_handler, table.unpack(t), ...)
        if is_ok then
            return fn_ret
        end
        return nil
    end
    return ret
end

function ParseArgs.parse_main_args(input_args, parse_fns, out_ret)
    out_ret = out_ret or {}
    local argc = #input_args
    local idx = 1
    while idx <= argc do
        local val = input_args[idx]
        local consume_arg_count = 0
        if ParseArgs.is_cmd_prefix(val) then
            if parse_fns[val] then
                consume_arg_count = parse_fns[val](input_args, idx + 1, out_ret)
            else
                -- 遇到没有处理函数的opt_name，把内容消耗掉就行
                consume_arg_count = ParseArgs.fill_args("unknown_opt", input_args, idx + 1, out_ret)
            end
        end
        idx = idx + 1 + consume_arg_count
    end
    return out_ret
end

local opt_op_fn_map = {
    [ParseArgs.Opt_C_Path] = ParseArgs.make_closure(ParseArgs.fill_args, ParseArgs.Opt_C_Path),
    [ParseArgs.Opt_Lua_Path] = ParseArgs.make_closure(ParseArgs.fill_args, ParseArgs.Opt_Lua_Path),
    [ParseArgs.Opt_Require_Files] = ParseArgs.make_closure(ParseArgs.fill_args, ParseArgs.Opt_Require_Files),
    [ParseArgs.Opt_Execute_Fns] = ParseArgs.make_closure(ParseArgs.fill_args, ParseArgs.Opt_Execute_Fns),
}
local setup_opt_op_fn_map = ParseArgs.setup_parse_fns(opt_op_fn_map)
--[[
for k, v in pairs(setup_opt_op_fn_map) do
    print("setup_opt_op_fn_map", k, v)
end
--]]

-- arg native传过来的全局变量
local arg_tb = ParseArgs.parse_main_args(arg, setup_opt_op_fn_map)
--[[
for k, v in pairs(arg_tb) do
    for sub_k, sub_v in pairs(v) do
        print("arg_tb", k, sub_k, sub_v)
    end
end
--]]
if arg_tb[ParseArgs.Opt_C_Path] then
    for _, v in pairs(arg_tb[ParseArgs.Opt_C_Path]) do
        ParseArgs.append_c_search_path(v)
    end
end
if arg_tb[ParseArgs.Opt_Lua_Path] then
    for _, v in pairs(arg_tb[ParseArgs.Opt_Lua_Path]) do
        ParseArgs.append_lua_search_path (v)
    end
end
for _, v in ipairs(require("pre_require_files")) do
    require(v)
end

if arg_tb[ParseArgs.Opt_Require_Files] then
    for _, v in ipairs(arg_tb[ParseArgs.Opt_Require_Files]) do
        require(v)
    end
end

if arg_tb[ParseArgs.Opt_Execute_Fns] then
    for _, fn_name in ipairs(arg_tb[ParseArgs.Opt_Execute_Fns]) do
        _G[fn_name](arg)
    end
end




