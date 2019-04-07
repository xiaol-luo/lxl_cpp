
ProtobufStore = ProtobufStore or class("ProtobufStore", ProtoStoreBase)

function ProtobufStore:ctor()
    self.pb = pb -- init_globala_vars:pb
    -- self.pb.option("use_default_metatable")
    self.pb.option("use_default_values")
    self.pb_loader = pb_protoc:new()
    self.default_tb = {}
end

function ProtobufStore:add_search_dirs(search_dirs)
    for _, v in pairs(search_dirs) do
        self.pb_loader:addpath(v)
    end
end

function ProtobufStore:load_files(files)
    log_debug("ProtobufStore:load_files %s", files)
    for _, v in pairs(files) do
        if not self.pb_loader:loadfile(v) then
            return false
        end
    end
    for name, basename, type in self.pb.types() do
        -- log_debug("ProtobufStore:load_files name:%s basename:%s type:%s", name, basename, type)
        self.default_tb[name] = self.pb.defaults(name)
    end
    return true
end

function ProtobufStore:encode(proto_name, param)
    local ret = self.pb.encode(proto_name, param or {})
    return ret
end

function ProtobufStore:decode(proto_name, blob)
    local ret = self.pb.decode(proto_name, blob)
    return ret
end