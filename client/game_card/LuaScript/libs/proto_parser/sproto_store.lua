
SprotoStore = SprotoStore or class("SprotoStore", ProtoStoreBase)

function SprotoStore:ctor()
    self.sps = {}
    -- self.proto_name_sp_map = {} -- todo: 提高效率
    self.search_dirs = {}
    table.insert(self.search_dirs, "")
    self.default_value_mts = {}
end

function SprotoStore:add_search_dirs(search_dirs)
    for _, v in pairs(search_dirs) do
        if v then
            table.insert(self.search_dirs, v)
        end
    end
end

function SprotoStore:load_files(files)
    local ret = true
    for _, file in pairs(files) do
        local parse_succ = false
        for _, dir in pairs(self.search_dirs) do
            local file_path = path.combine(dir, file)
            local f = io.open(file_path)
            if f then
                local f_content = f:read("a")
                io.close(f)
                local fn = function()
                    local pbin = sproto_parser.parse(f_content, file_path)
                    local sp = sproto.new(pbin)
                    table.insert(self.sps, sp)
                    parse_succ = nil ~= sp
                end
                safe_call(fn)
                break
            end
        end
        if not parse_succ then
            ret = false
            break
        end
    end
    return ret
end

function SprotoStore:get_sp(pto_name)
    local sp = nil
    for _, v in pairs(self.sps) do -- todo: 提高效率
        if v:exist_type(pto_name) then
            sp = v
            break
        end
    end
    return sp
end

function SprotoStore:encode(pto_name, param)
    local is_ok = false
    local ret = "pto_type not found"
    local sp = self:get_sp(pto_name)
    if sp then
        param = param or {}
        is_ok, ret = safe_call(sp.encode, sp, pto_name, param)
    end
    return is_ok, ret
end

function SprotoStore:decode(pto_name, blob)
    local is_ok = false
    local ret = "pto_type not found"
    local sp = self:get_sp(pto_name)
    if sp then
        local default_val_mt = self.default_value_mts[pto_name]
        if not default_val_mt then
            default_val_mt = {}
            default_val_mt.__index = sp:default(pto_name)
            self.default_value_mts[pto_name] = default_val_mt
        end
        is_ok, ret = safe_call(sp.decode, sp, pto_name, blob)
        if is_ok then
            setmetatable(ret, default_val_mt)
        end
    end
    return is_ok, ret
end