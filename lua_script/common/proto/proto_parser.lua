
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

function ProtoParser:decode(proto_id, param)
    local ret = nil
    local proto_detail = self.id2proto_detail[proto_id]
    if proto_detail then
        ret = proto_detail[Const.Store]:decode(proto_detail[Const.Name], param)
    else
        log_warn("ProtoParser:decode find no proto_detail of proto id %s", proto_id)
    end
    return ret
end



