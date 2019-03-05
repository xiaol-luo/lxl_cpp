
mongo_opt_field_name = {}
mongo_opt_field_name.max_time = native.mongo_opt_field_name.max_time
mongo_opt_field_name.projection = native.mongo_opt_field_name.projection
mongo_opt_field_name.upsert = native.mongo_opt_field_name.upsert
mongo_opt_field_name.sort = native.mongo_opt_field_name.sort
mongo_opt_field_name.limit = native.mongo_opt_field_name.limit
mongo_opt_field_name.min = native.mongo_opt_field_name.min
mongo_opt_field_name.max = native.mongo_opt_field_name.max
mongo_opt_field_name.skip = native.mongo_opt_field_name.skip

mongo_opt_base = mongo_opt_base or class("mongo_opt_base")
function mongo_opt_base:to_json() 
   assert(false, "should be implete by subclass")
end


-- MongoOptFind
MongoOptFind = MongoOptFind or class("MongoOptFind", mongo_opt_base)

function MongoOptFind:ctor()
    self[mongo_opt_field_name.max_time] = nil
    self[mongo_opt_field_name.projection] = nil
    self[mongo_opt_field_name.sort] = nil
    self[mongo_opt_field_name.limit] = nil
    self[mongo_opt_field_name.min] = nil
    self[mongo_opt_field_name.max] = nil
    self[mongo_opt_field_name.skip] = nil
end

function mongo_opt_base:to_json()
    local tb = {}
    tb[mongo_opt_field_name.max_time] = self:get_max_time()
    tb[mongo_opt_field_name.projection] = self:get_projection()
    tb[mongo_opt_field_name.sort] = self:get_sort()
    tb[mongo_opt_field_name.limit] = self:get_limit()
    tb[mongo_opt_field_name.min] = self:get_min()
    tb[mongo_opt_field_name.max] = self:get_max()
    tb[mongo_opt_field_name.skip] = self:get_skip()
    local ret = rapidjson.encode(tb)
    return ret
end

function MongoOptFind:set_max_time(ms)
    self[mongo_opt_field_name.max_time] = tonumber(ms)
end

function MongoOptFind:get_max_time()
    return self[mongo_opt_field_name.max_time] or 10 * 1000 -- 默认10s
end

function MongoOptFind:set_projection(tb)
    self[mongo_opt_field_name.projection] = tb
end

function MongoOptFind:get_projection()
    return self[mongo_opt_field_name.projection]
end

function MongoOptFind:set_sort(tb)
    self[mongo_opt_field_name.sort] = tb
end

function MongoOptFind:get_sort()
    return self[mongo_opt_field_name.sort]
end

function MongoOptFind:set_limit(val)
    self[mongo_opt_field_name.limit] = val
end

function MongoOptFind:get_limit()
    return self[mongo_opt_field_name.limit]
end

function MongoOptFind:set_min(tb)
    self[mongo_opt_field_name.min] = tb
end

function MongoOptFind:get_min()
    return self[mongo_opt_field_name.min]
end

function MongoOptFind:set_max(tb)
    self[mongo_opt_field_name.max] = tb
end

function MongoOptFind:get_max()
    return self[mongo_opt_field_name.max]
end

function MongoOptFind:set_skip(val)
    self[mongo_opt_field_name.skip] = val
end

function MongoOptFind:get_skip()
    return self[mongo_opt_field_name.skip]
end

-- MongoOptUpdate
MongoOptUpdate = MongoOptUpdate or class("MongoOptUpdate", mongo_opt_base)

function MongoOptUpdate:ctor()
    self[mongo_opt_field_name.upsert] = nil
end

function MongoOptUpdate:to_json()
    local tb = {}
    tb[mongo_opt_field_name.upsert] = self:get_upsert()
    local ret = rapidjson.encode(tb)
    return ret
end

function MongoOptUpdate:set_upsert(val)
    self[mongo_opt_field_name.upsert] = val
end

function MongoOptUpdate:get_upsert(ms)
    return self[mongo_opt_field_name.upsert]
end

-- MongoOptFindOneAndUpdate
MongoOptFindOneAndUpdate = MongoOptFindOneAndUpdate or class("MongoOptFindOneAndUpdate", mongo_opt_base)

function MongoOptFindOneAndUpdate:ctor()
    self[mongo_opt_field_name.upsert] = nil
    self[mongo_opt_field_name.projection] = nil
end

function MongoOptFindOneAndUpdate:to_json()
    local tb = {}
    tb[mongo_opt_field_name.upsert] = self:get_upsert()
    tb[mongo_opt_field_name.projection] = self:get_projection()
    local ret = rapidjson.encode(tb)
    return ret
end

function MongoOptFindOneAndUpdate:set_upsert(val)
    self[mongo_opt_field_name.upsert] = val
end

function MongoOptFindOneAndUpdate:get_upsert()
    return self[mongo_opt_field_name.upsert]
end

function MongoOptFindOneAndUpdate:set_projection(tb)
    self[mongo_opt_field_name.projection] = tb
end

function MongoOptFindOneAndUpdate:get_projection()
    return self[mongo_opt_field_name.projection]
end
