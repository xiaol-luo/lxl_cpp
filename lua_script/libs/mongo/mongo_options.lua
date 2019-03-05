
mongo_opt_field_name = {}
mongo_opt_field_name.max_time = native.mongo_opt_field_name.max_time
mongo_opt_field_name.projection = native.mongo_opt_field_name.projection
mongo_opt_field_name.upsert = native.mongo_opt_field_name.upsert

mongo_opt_base = mongo_opt_base or class("mongo_opt_base")
function mongo_opt_base:to_json() 
   assert(false, "should be implete by subclass")
end


-- MongoOptFind
MongoOptFind = MongoOptFind or class("MongoOptFind", mongo_opt_base)

function MongoOptFind:ctor()
    self[mongo_opt_field_name.max_time] = nil
    self[mongo_opt_field_name.projection] = nil
end

function mongo_opt_base:to_json()
    local tb = {}
    tb[mongo_opt_field_name.max_time] = self[mongo_opt_field_name.max_time]
    tb[mongo_opt_field_name.projection] = self[mongo_opt_field_name.projection]
    local ret = rapidjson.encode(tb)
    return ret
end

function MongoOptFind:set_max_time(ms)
    self[mongo_opt_field_name.max_time] = ms
end

function MongoOptFind:get_max_time()
    return self[mongo_opt_field_name.max_time]
end

function MongoOptFind:set_projection(tb)
    self[mongo_opt_field_name.projection] = tb
end

function MongoOptFind:get_projection()
    return self[mongo_opt_field_name.projection]
end

-- MongoOptUpdate
MongoOptUpdate = MongoOptUpdate or class("MongoOptUpdate", mongo_opt_base)

function MongoOptUpdate:ctor()
    self[mongo_opt_field_name.upsert] = nil
end

function MongoOptUpdate:to_json()
    local tb = {}
    tb[mongo_opt_field_name.upsert] = self[mongo_opt_field_name.upsert]
    local ret = rapidjson.encode(tb)
    return ret
end

function MongoOptUpdate:set_upsert(ms)
    self[mongo_opt_field_name.upsert] = ms
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
    tb[mongo_opt_field_name.upsert] = self[mongo_opt_field_name.upsert]
    tb[mongo_opt_field_name.projection] = self[mongo_opt_field_name.projection]
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
