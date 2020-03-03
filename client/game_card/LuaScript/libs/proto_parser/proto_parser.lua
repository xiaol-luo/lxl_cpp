
 ProtoParser = ProtoParser or class("ProtoParser")

function ProtoParser:ctor()
    self.stores = {}
    self.stores[Proto_Const.Pb] = ProtobufStore:new()
    self.stores[Proto_Const.Sproto] = SprotoStore:new()
    self.id2proto_detail = {}
end

function ProtoParser:add_search_dirs(search_dirs)
    for _, v in pairs(self.stores) do
        v:add_search_dirs(search_dirs)
    end
end

local set_proto_detail = function(proto_parser, id, store_name, proto_name)
    assert(id)
    assert(proto_name)
    assert(proto_parser)
    assert(store_name)
    local store = proto_parser.stores[store_name]
    assert(store)
    assert(not proto_parser.id2proto_detail[id])
    proto_parser.id2proto_detail[id] = { [Proto_Const.Id] = id, [Proto_Const.Store] = store, [Proto_Const.Name] = proto_name }
end

function ProtoParser:init(load_files, pid_proto_map)
    -- load_files = {"pb"={}, "sproto"={}}
    local ret = true
    for k, v in pairs(self.stores) do
        assert(System_Proto_Files[k])
        -- log_debug("ProtoParser:init system proto files %s", k)
        ret = v:load_files(System_Proto_Files[k])
        if not ret then
            break
        end
    end
    assert(ret)
    -- setup proto_id->proto_detail map
    for _, v  in ipairs(System_Pid_Proto_Map) do
        set_proto_detail(self, v[Proto_Const.Proto_Id], v[Proto_Const.Proto_Type], v[Proto_Const.Proto_Name])
    end

    for k, v in pairs(self.stores) do
        if load_files[k] then
            -- log_debug("ProtoParser:init custom proto files %s", k)
            ret = v:load_files(load_files[k])
            if not ret then
                break
            end
        end
    end
    assert(ret)
    -- setup proto_id->proto_detail map
    for _, v  in ipairs(pid_proto_map) do
        set_proto_detail(self, v[Proto_Const.Proto_Id], v[Proto_Const.Proto_Type], v[Proto_Const.Proto_Name])
    end
    return ret
end

 function ProtoParser:exist(proto_id)
     if self.id2proto_detail[proto_id] then
         return true
     end
     return false
 end

function ProtoParser:encode(proto_id, param)
    local proto_detail = self.id2proto_detail[proto_id]
    assert(proto_detail)
    return proto_detail[Proto_Const.Store]:encode(proto_detail[Proto_Const.Name], param)
end

function ProtoParser:decode(proto_id, block)
    local is_ok = true
    local ret = nil
    local proto_detail = self.id2proto_detail[proto_id]
    if proto_detail then
        is_ok, ret = proto_detail[Proto_Const.Store]:decode(proto_detail[Proto_Const.Name], block)
    end
    return is_ok, ret
end

function ProtoParser:encode_by_name(proto_type, proto_name, tb)
    local store = self.stores[proto_type]
    assert(store)
    return store:encode(proto_name, tb)
end

function ProtoParser:decode_by_name(proto_type, proto_name, block)
    local store = self.stores[proto_type]
    assert(store)
    return store:decode(proto_name, block)
end

function ProtoParser:pb_encode(proto_name, tb)
    return self:encode_by_name(Proto_Const.Pb, proto_name, tb)
end

function ProtoParser:pb_decode(proto_name, block)
    return self:decode_by_name(Proto_Const.Pb, proto_name, block)
end

function ProtoParser:sproto_encode(proto_name, tb)
    return self:encode_by_name(Proto_Const.Sproto, proto_name, tb)
end

function ProtoParser:sproto_decode(proto_name, block)
    return self:decode_by_name(Proto_Const.Sproto, proto_name, block)
end

 function parse_proto(search_dirs, proto_files, pid_proto_map)
     local ret = ProtoParser:new()
     -- log_debug(proto_dir)
     ret:add_search_dirs(search_dirs)
     proto_files = proto_files or {}
     pid_proto_map = pid_proto_map or {}
     local is_ok = ret:init(proto_files, pid_proto_map)
     return is_ok and ret or nil
 end




