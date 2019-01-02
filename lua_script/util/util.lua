--[[
util = util or {}
local c_one_gang = "-"
local opt_lua_path = "lua_path"
local opt_c_path = "c_path"
local opt_logic = "logic"

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
    local parse_fns = {}
    parse_fns[c_one_gang .. opt_lua_path] = function(args, arg_idx, ret)
        return fn_fill_args(args, arg_idx, ret, opt_lua_path)
    end
    parse_fns[c_one_gang .. opt_c_path] = function(args, arg_idx, ret)
        return fn_fill_args(args, arg_idx, ret, opt_c_path)
    end
    parse_fns[c_one_gang .. opt_logic] = function(args, arg_idx, ret)
        return fn_fill_args(args, arg_idx, ret, opt_logic)
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

function util.use_parse_main_ret(ret)
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

function util.append_lua_search_path(v)
    package.path = string.format("%s;%s/?.lua;%s/?/init.lua", package.path, v, v)
end

function util.append_c_search_path(v)
    package.cpath = string.format("%s;%s/?.dll;", package.cpath, v)
end
--]]