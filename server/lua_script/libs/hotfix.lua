
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
                if name and #name > 0 and "_ENV" ~= name then
                    up_names[name] = true
                end
            end
        end
    end
    local lua_code = "local function fn() return end\n return fn"
    do
        local up_names_array = {}
        for k, _ in pairs(up_names) do
            table.insert(up_names_array, k)
        end
        local code_variables = table.concat(up_names_array, ",")
        local chs_val = { [' ']=true, [',']=true }
        local idx = 0
        for i = #code_variables, 1, -1 do
            if not chs_val[string.byte(code_variables, i)] then
                idx = i
                break
            end
        end
        code_variables = idx < 1 and "" or string.sub(code_variables, 1, idx)
        if #code_variables > 0 then
            lua_code = string.format("local %s = nil \n local function fn() return %s end\n return fn",
                    code_variables, code_variables)
        end

    end
    -- print("hotfix_record_module_upvalues lua_code:\n", lua_code)
    local lf, errmsg = load(lua_code)
    assert(lf, errmsg)
    debug.setupvalue(lf, 1, mod)
    local out_fn = lf()
    -- print("hotfix_record_module_upvalues mod=", mod)
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
    -- print("hotfix_record_module_upvalues upvalues:\n", Functional.varlen_param_info(out_fn()))
end

function hotfix_function(old_fn, new_fn, mod)
    -- print("hotfix_function 1", tostring(old_fn), tostring(new_fn), mod)
    local idx = 0
    while true do
        idx = idx + 1
        local name = debug.getupvalue(new_fn, idx)
        if not name then
            break
        end
        local old_idx = 0
        local joined = false
        while true do
            old_idx = old_idx + 1
            local old_name = debug.getupvalue(old_fn, old_idx)
            if not old_name then
                break
            end
            if name == old_name then
                debug.upvaluejoin(new_fn, idx, old_fn, old_idx)
                -- print("hotfix_function upvalue 1", name)
                joined = true
                break
            end
        end
        if not joined and mod and "function" == type(mod.__ups) then
            old_idx = 0
            while true do
                old_idx = old_idx + 1
                local old_name = debug.getupvalue(mod.__ups, old_idx)
                if not old_name then
                    break
                end
                if name == old_name then
                    -- print("hotfix_function upvalue 2", name)
                    debug.upvaluejoin(new_fn, idx, mod.__ups, old_idx)
                    joined = true
                    break
                end
            end
        end
    end
    -- 用new_fn的proto替换old_fn的proto
    debug.replace_proto(old_fn, new_fn)
    -- 用new_fn的upvalues替换old_fn的upvalues
    debug.copy_upvalues(old_fn, new_fn)
    if mod then
        hotfix_record_module_upvalues(mod)
    end
    -- print("hotfix_function 1", tostring(old_fn), tostring(new_fn), mod)
end

function hotfix_module(old_mod, new_mod)
    local opt = {
        replace_fn = true,
        replace_var = false,
    }
    hotfix_table(old_mod, new_mod, opt, {})
end

local protection = {
    setmetatable = true,
    pairs = true,
    iparis = true,
    require = true,
    _ENV = true,
}

function hotfix_table(old_tb, new_tb, opt, visited_record)
    -- 第一原则：只增不减。若旧表有，新表没有，无论如何，保留旧表的值；若旧表没有，新表有，拷贝新表的值到旧表
    -- replace的行为是：遵循第一原则的情况下，若旧表和新表都有，则用新表的值替换旧表的值
    -- opt.replace_var
    -- opt.replace_fn

    --对某些关键函数不进行比对
    if protection[old_tb] or protection[new_tb] then
        return
    end
    --如果原值与当前值内存一致，值一样不进行对比
    if old_tb == new_tb then
        return
    end
    local signature = tostring(old_tb) .. tostring(new_tb)
    -- print("hotfix_table signature", signature)
    if visited_record[signature] then
        return
    end
    visited_record[signature] = true
    for k, new_val in pairs(new_tb) do
        local new_val_type = type(new_val)
        local old_val = old_tb[k]
        if nil == old_val then
            if "function" == new_val_type then
                old_tb[k] = function() end
                hotfix_function(old_tb[k], new_val, old_tb)
            else
                old_tb[k] = new_val
            end
        else
            local old_value_type = type(old_val)
            if old_value_type ~= new_val_type then
                -- print("hotfix_table warning type not match !")
            end
            if "function" == old_value_type then
                if opt.replace_fn then
                    hotfix_function(old_val, new_val, old_tb)
                end
            else
                if "table" == old_value_type then
                    hotfix_table(old_val, new_val, opt, visited_record)
                else
                    if opt.replace_var then
                        old_tb[k] = new_val
                    end
                end
            end
        end
    end
    local old_meta = debug.getmetatable(old_tb)
    local new_meta = debug.getmetatable(new_tb)
    if "table" == type(old_meta) and "table" == type(new_meta) then
        -- hotfix_table(old_meta, new_meta, opt, visited_record)
    end
end

function hotfix_read_file(file_path)
    local file_content = nil
    local tmp_paths = string.split(file_path, ".")
    local real_file_path = table.concat(tmp_paths, "/")
    local search_paths = string.split(package.path, ";")
    for _, v in ipairs(search_paths) do
        local full_path = string.gsub(v, "%?", real_file_path)
        local file_attr = lfs.attributes(full_path)
        -- print("hotfix_file", full_path, file_attr or "nil")
        if file_attr and "file" == file_attr.mode then
            local fd = io.open(full_path, "r")
            if fd then
                file_content = fd:read("a")
                fd:close()
                break
            end
        end
    end
    return file_content
end

function hotfix_build_env(old_env_tb, chunk, chunk_name)
    local env = {}
    setmetatable(env, {
        __index = old_env_tb,
        __newindex = function(self, k, v)
            -- print("__newindex", k, tostring(v))
            if nil == v then
                rawset(self, k, v)
                -- print("__newindex 1", k, tostring(v))
                return
            end
            if "table" ~= type(v) then
                -- print("__newindex 2", k, tostring(v))
                rawset(self, k, v)
                return
            end
            local local_v = rawget(self, k)
            if local_v == v then
                -- print("__newindex 3", k, tostring(v))
                return
            end
            if not local_v then
                -- print("__newindex 4", k, tostring(v))
                local_v = {}
                setmetatable(local_v, {__index = v})
                rawset(self, k, local_v)
                return
            end
            -- print("__newindex 5", k, tostring(v))
        end
    })
    local lf, error_msg = load(chunk, chunk_name)
    if not lf then
        print("hotfix_build_env load fail:", error_msg)
        return nil
    end
    debug.setupvalue(lf, 1, env)
    local n, rets = Functional.varlen_param_info(pcall(lf))
    local ok = rets[1]
    if not ok then
        local error_msg = rets[2]
        print("hotfix_build_env pcall fail:", error_msg)
        return nil
    end
    return env, table.unpack(rets, 2)
end

function hotfix_chunk(old_env_tb, chunk, chunk_name)
    local env = hotfix_build_env(old_env_tb, chunk, chunk_name)
    if not env then
        return
    end
    local opt = {
        replace_fn = true,
        replace_var = false,
    }
    hotfix_table(old_env_tb, env, opt, {})
end

function hotfix_file(file_path, old_env_tb)
    if not old_env_tb then
        old_env_tb = _G
    end
    local file_content = hotfix_read_file(file_path)
    if not file_content then
        print("hotfix_file fail, can not read file", file_path)
        return
    end
    hotfix_chunk(old_env_tb, file_content, file_path)
end

function batch_hotfix_files(file_paths, old_env_tb)
    for _, v in pairs(file_paths) do
        hotfix_file(v, old_env_tb)
    end
end


-- 下面的是为了处理用local定义类的情况
function hotfix_require(file_path)
    local file_content = hotfix_read_file(file_path)
    if not file_content then
        print("hotfix_file fail, can not read file", file_path)
        return
    end
    local old_env = _G
    local old_n, old_ret = Functional.varlen_param_info(require(file_path))
    local new_n, new_ret = Functional.varlen_param_info(hotfix_build_env(_G, file_content, file_path))
    local new_env = new_ret[1]
    if not new_env then
        return
    end    
    table.remove(new_ret, 1)

    local opt = {
        replace_fn = true,
        replace_var = true,
        replace_upvalue = true,
    }
    hotfix_table(old_env, new_env, opt, {})
    hotfix_table(old_ret, new_ret, opt, {})
end

function batch_hotfix_require(file_paths)
    for _, v in pairs(file_paths) do
        hotfix_require(v)
    end
end

