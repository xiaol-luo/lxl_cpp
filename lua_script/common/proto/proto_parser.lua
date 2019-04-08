
ProtoParser = ProtoParser or class("ProtoParser")
ProtoParser.Const = {}
ProtoParser.Const.Pb = "pb"
ProtoParser.Const.Sproto = "sproto"
ProtoParser.Const.Store = "store"
ProtoParser.Const.Name = "name"
ProtoParser.Const.Id = "id"

local Const = ProtoParser.Const

function ProtoParser:ctor()
    self.stores = {}
    self.stores[Const.Pb] = ProtobufStore:new()
    self.stores[Const.Sproto] = SprotoStore:new()
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
    proto_parser.id2proto_detail[id] = { [Const.Id] = id, [Const.Store] = store, [Const.Name] = proto_name }
end

function ProtoParser:init(load_files)
    -- load_files = {"pb"={}, "sproto"={}}
    local ret = true
    for k, v in pairs(self.stores) do
        assert(load_files[k])
        log_debug("ProtoParser:init %s", k)
        ret = v:load_files(load_files[k])
        if not ret then
            break
        end
    end
    -- setup proto_id->proto_detail map
    -- set_proto_detail(self, 1, Const.Pb, "Ping")
    -- set_proto_detail(self, 2, Const.Pb, "Pong")
    set_proto_detail(self, 5, Const.Sproto, "TestSproto")
    set_proto_detail(self, 6, Const.Pb, "TestPb")

    return ret
end

function ProtoParser:encode(proto_id, param)
    local proto_detail = self.id2proto_detail[proto_id]
    assert(proto_detail)
    return proto_detail[Const.Store]:encode(proto_detail[Const.Name], param)
end

function ProtoParser:decode(proto_id, block)
    local is_ok = true
    local ret = {}
    local proto_detail = self.id2proto_detail[proto_id]
    if proto_detail then
        is_ok, ret = proto_detail[Const.Store]:decode(proto_detail[Const.Name], block)
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
    return self:encode_by_name(Const.Pb, proto_name, tb)
end

function ProtoParser:pb_decode(proto_name, block)
    return self:decode_by_name(Const.Pb, proto_name, block)
end

function ProtoParser:sproto_encode(proto_name, tb)
    return self:encode_by_name(Const.Sproto, proto_name, tb)
end

function ProtoParser:sproto_decode(proto_name, block)
    return self:decode_by_name(Const.Sproto, proto_name, block)
end




