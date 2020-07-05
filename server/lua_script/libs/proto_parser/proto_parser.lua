
---@class ProtoParser
ProtoParser = ProtoParser or class("ProtoParser")

function ProtoParser:ctor()
    self.stores = {}
    self.stores[Pto_Const.Pb] = ProtobufStore:new()
    self.stores[Pto_Const.Sproto] = SprotoStore:new()
    self.id2proto_detail = {}
end

function ProtoParser:add_search_dirs(search_dirs)
    for _, v in pairs(self.stores) do
        v:add_search_dirs(search_dirs)
    end
end

 function ProtoParser:load_file(pto_type, file)
     local ret = false
     local store = self.stores[pto_type]
     if store and store:load_files({file}) then
         ret = true
     else
         log_error("ProtoParser:load_files fail, file=%s", v)
     end
     return ret
 end

 function ProtoParser:load_files(file_list)
     local ret = true
     for _, v in pairs(file_list) do
         if not self:load_file(v[Pto_Const.pto_type], v[Pto_Const.pto_path]) then
             ret = false
         end
     end
     return ret
 end

 function ProtoParser:setup_id_to_proto(pto_id, pto_type, pto_name)
     assert(pto_type and pto_id and pto_name)
     local store = self.stores[pto_type]
     assert(store)
     assert(not self.id2proto_detail[pto_id])
     self.id2proto_detail[pto_id] = { [Pto_Const.pto_id] = pto_id, [Pto_Const.pto_type] = store, [Pto_Const.pto_name] = pto_name }
 end

 function ProtoParser:setup_id_to_protos(pto_list)
     for _, v in pairs(pto_list) do
         self:setup_id_to_proto(v[Pto_Const.pto_id], v[Pto_Const.pto_type], v[Pto_Const.pto_name])
     end
 end

 function ProtoParser:exist(pto_id)
     if self.id2proto_detail[pto_id] then
         return true
     end
     return false
 end

function ProtoParser:encode(pto_id, param)
    local is_ok, ret = false, nil
    local proto_detail = self.id2proto_detail[pto_id]
    if proto_detail then
        is_ok, ret = proto_detail[Pto_Const.pto_type]:encode(proto_detail[Pto_Const.pto_name], param)
    end
    return is_ok, ret
end

function ProtoParser:decode(pto_id, block)
    local is_ok = false
    local ret = nil
    local proto_detail = self.id2proto_detail[pto_id]
    if proto_detail then
        is_ok, ret = proto_detail[Pto_Const.pto_type]:decode(proto_detail[Pto_Const.pto_name], block)
    end
    return is_ok, ret
end

function ProtoParser:encode_by_name(pto_type, pto_name, tb)
    local store = self.stores[pto_type]
    assert(store)
    return store:encode(pto_name, tb)
end

function ProtoParser:decode_by_name(pto_type, pto_name, block)
    local store = self.stores[pto_type]
    assert(store)
    return store:decode(pto_name, block)
end

function ProtoParser:pb_encode(pto_name, tb)
    return self:encode_by_name(Pto_Const.Pb, pto_name, tb)
end

function ProtoParser:pb_decode(pto_name, block)
    return self:decode_by_name(Pto_Const.Pb, pto_name, block)
end

function ProtoParser:sproto_encode(pto_name, tb)
    return self:encode_by_name(Pto_Const.Sproto, pto_name, tb)
end

function ProtoParser:sproto_decode(pto_name, block)
    return self:decode_by_name(Pto_Const.Sproto, pto_name, block)
end





