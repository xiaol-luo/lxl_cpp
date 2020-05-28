
ProtobufStore = ProtobufStore or class("ProtobufStore", ProtoStoreBase)

function ProtobufStore:ctor()
    self.pb = pb -- init_globala_vars:pb
    self.pb.option("use_default_metatable")
    -- self.pb.option("use_default_values")
    self.pb_loader = pb_protoc:new()
    -- self.default_tb = {}
end

function ProtobufStore:add_search_dirs(search_dirs)
    for _, v in pairs(search_dirs) do
        self.pb_loader:addpath(v)
    end
end

function ProtobufStore:load_files(files)
    -- log_debug("ProtobufStore:load_files %s", files)
    local ret = true
    for _, v in pairs(files) do
        if not self.pb_loader:loadfile(v) then
            ret = false
            break
        end
    end
    for name, basename, type in self.pb.types() do
        -- log_debug("ProtobufStore:load_files name:%s basename:%s type:%s", name, basename, type)
        -- self.default_tb[name] = self.pb.defaults(name)
    end
    return ret
end

function ProtobufStore:encode(pto_name, param)
    local is_ok, ret = safe_call(self.pb.encode, pto_name, param or {})
    return is_ok, ret
end

function ProtobufStore:decode(pto_name, blob)
    blob = blob or ""
    local is_ok, ret = safe_call(self.pb.decode, pto_name, blob)
    return is_ok, ret
end