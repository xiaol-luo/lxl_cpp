
SprotoStore = SprotoStore or class("SprotoStore", ProtoStoreBase)

function SprotoStore:ctor()
    self.sps = {}
    -- self.proto_name_sp_map = {} -- todo: 提高效率
    self.search_dirs = {}
    table.insert(self.search_dirs, "")
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
            local file_attrs = lfs.attributes(file_path)
            if file_attrs then -- todo: 增加错误处理
                local f = io.open(file_path)
                local f_content = f:read("a")
                io.close(f)
                local pbin = sproto_parser.parse(f_content, file_path)
                local sp = sproto.new(pbin)
                table.insert(self.sps, sp)
                parse_succ = nil ~= sp
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

function SprotoStore:get_sp(proto_name)
    local sp = nil
    for _, v in pairs(self.sps) do
        if v:exist_type(proto_name) then
            sp = v
            break
        end
    end
    return sp
end

function SprotoStore:encode(proto_name, param)
    local ret = nil
    local sp = self:get_sp(proto_name)
    if sp then
        param = param or {}
        ret = sp:encode(proto_name, param)
    end
    return ret
end

function SprotoStore:decode(proto_name, blob)
    local ret = nil
    local sp = self:get_sp(proto_name)
    if sp then
        ret = sp:decode(proto_name, blob)
    end
    return ret
end