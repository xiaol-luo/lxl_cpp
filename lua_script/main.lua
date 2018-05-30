
local function parse_cmd_args(out_ret)
    local fn_is_cmd_prefix = function(s)
        local ret = string.find(s, "-") == 1
        return ret
    end

    local TbKey_Package_Path = "package_path"
    local TbKey_Package_CPath = "package_cpath"

    local parse_fns = {}
    parse_fns["-package_path"] = function(args, arg_idx, ret)
        ret[TbKey_Package_Path] = ret[TbKey_Package_Path] or {}
        local t = ret[TbKey_Package_Path]
        local curr_idx = arg_idx
        while curr_idx <= #args do
            local curr_arg = args[curr_idx]
            if fn_is_cmd_prefix(curr_arg) then
                break
            end
            table.insert(t, curr_arg)
            curr_idx = curr_idx + 1
        end
        return curr_idx - arg_idx
    end
    parse_fns["-package_cpath"] = function(args, arg_idx, ret)
        ret["package_cpath"] = ret["package_cpath"] or {}
        local t = ret["package_cpath"]
        local curr_idx = arg_idx
        while curr_idx <= #args do
            local curr_arg = args[curr_idx]
            if fn_is_cmd_prefix(curr_arg) then
                break
            end
            table.insert(t, curr_arg)
            curr_idx = curr_idx + 1
        end
        return curr_idx - arg_idx
    end

    out_ret = out_ret or {}
    local all_ok = true
    local arg_idx = 1
    while arg_idx <= #arg do
        local curr_arg = arg[arg_idx]
        if not fn_is_cmd_prefix(curr_arg) then
            all_ok = false
            break
        end
        local fn = parse_fns[curr_arg]
        if nil == fn then
            all_ok = false
            break
        end
        local consume_arg_count = fn(arg, arg_idx + 1, out_ret)
        arg_idx = arg_idx + 1 + consume_arg_count
    end
    if all_ok then
        for _, v in ipairs(out_ret[TbKey_Package_Path]) do
            if v then
                package.path = string.format("%s;%s/?.lua;%s/?/init.lua", package.path, v, v)
            end
        end
        for _, v in ipairs(out_ret[TbKey_Package_CPath]) do
            if v then
                package.cpath = string.format("%s;%s/?.dll;", package.cpath, v)
            end
        end
    end
    return all_ok
end

print("before parse \n")
print("package.cpath:")
print(package.cpath)
print("\n")
print("package.path:")
print(package.path)

out_ret = {}
parse_cmd_args(out_ret)

print("after parse \n")
print("before parse \n")
print("package.cpath:")
print(package.cpath)
print("\n")
print("package.path:")
print(package.path)

require "test"
require "testall"


