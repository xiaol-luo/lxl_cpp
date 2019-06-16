
function hotfix_replace_one_upvalue(new_fn, name, idx, old_fn)
    local _idx = 0
    while true do
        _idx = _idx + 1
        local _name = debug.getupvalue(old_fn, _idx)
        if _name == name then
            debug.upvaluejoin(new_fn, idx, old_fn, _idx)
            return true
        end
    end
    return false
end

function hotfix_function(old_fn, new_fn)
    local idx = 0
    while true do
        idx = idx + 1
        local name = debug.getupvalue(new_fn, idx)
        if not name then
            break
        end
        local old_idx = 0
        while true do
            old_idx = old_idx + 1
            local old_name = debug.getupvalue(old_fn, old_idx)
            if not old_name then
                break
            end
            if name == old_name then
                debug.upvaluejoin(new_fn, idx, old_fn, old_idx)
                break
            end
        end
    end
    -- 用new_fn的proto替换old_fn的proto
    debug.replace_proto(old_fn, new_fn)
    -- 用new_fn的upvalues替换old_fn的upvalues
    debug.copy_upvalues(old_fn, new_fn)
end

function hotfix_record_module_upvalues(mod)
    local up_names = {}
    for _, v in pairs(mod) do
        local i = 0
        if "function" == type(v) then
            while true do
                i = i + 1
                local name = debug.getupvalue(v, i)
                if not name then
                    break
                end
                if "_ENV" ~= name then
                    up_names[name] = true
                end
            end
        end
    end
    local lua_code = ""
    do
        local code_variables = ""
        for name, _ in pairs(up_names) do
            code_variables = code_variables ..
                    string.format("%s,", name)
        end
        if #code_variables > 0 then
            code_variables = string.sub(code_variables, 1, #code_variables - 1)
        end
        lua_code = string.format("local %s = nil \n local function fn() return %s end\n return fn",
                code_variables, code_variables)

    end
    print("code string \n", lua_code)
    local lf, errmsg = load(lua_code)
    assert(lf, errmsg)
    debug.setupvalue(lf, 1, mod)
    local out_fn = lf()
    print("xxxxxxxxxx", Functional.varlen_param_info(out_fn()))
    print("mod", mod)
    local idx = 0
    while true do
        idx = idx + 1
        local name = debug.getupvalue(out_fn, idx)
        if not name then
            break
        end
        local saved = false
        for _, v in pairs(mod) do
            if "function" == type(v) then
                local _idx = 0
                while true do
                    _idx = _idx + 1
                    local _name = debug.getupvalue(v, _idx)
                    if not _name then
                        break
                    end
                    if _name == name then
                        debug.upvaluejoin(out_fn, idx, v, _idx)
                        saved = true
                        break
                    end
                end
            end
            if saved then
                break
            end
        end
    end
    mod.__ups = out_fn
    print("after update upvalue \nxxxxxxxxxx", Functional.varlen_param_info(out_fn()))
    print("mod", mod)
end