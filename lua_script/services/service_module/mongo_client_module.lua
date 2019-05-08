
MongoClientModule = MongoClientModule or class("MongoClientModule", ServiceModule)

function MongoClientModule:ctor(module_mgr, module_name)
    MongoClientModule.super.ctor(self, module_mgr, module_name)
    self.mongo_client = nil
    self.Thread_Num = 3
end

function MongoClientModule:init(hosts, auth_db, user_name, pwd)
    MongoClientModule.super.init(self)
    self.mongo_client = MongoClient:new(self.Thread_Num, hosts, auth_db, user_name, pwd)
end

function MongoClientModule:start()
    self.curr_state = ServiceModuleState.Starting
    local ret = self.mongo_client:start()
    if not ret then
        self.error_num = 1
        self.error_msg = "start fail"
    else
        self.curr_state = ServiceModuleState.Started
    end
end

function MongoClientModule:stop()
    self.curr_state = ServiceModuleState.Stopped
    self.mongo_client:stop()
end

function MongoClientModule:on_update()
    self.mongo_client:on_tick()
end

-- cb_fn = function(result_tb) end
-- opt = MongoOptFind
function MongoClientModule:find_one(hash_code, db, coll, filter, cb_fn, opt)
    return self.mongo_client:find_one(hash_code, db, coll, filter, cb_fn, opt)
end

function MongoClientModule:find_many(hash_code, db, coll, filter, cb_fn, opt)
    return self.mongo_client:find_many(hash_code, db, coll, filter, cb_fn, opt)
end

function MongoClientModule:insert_one(hash_code, db, coll, doc, cb_fn)
    return self.mongo_client:insert_one(hash_code, db, coll, doc, cb_fn)
end

function MongoClientModule:insert_many(hash_code, db, coll, doc_array, cb_fn)
    return self.mongo_client:insert_many(hash_code, db, coll, doc_array, cb_fn)
end

function MongoClientModule:delete_one(hash_code, db, coll, filter, cb_fn)
    return self.mongo_client:delete_one(hash_code, db, coll, filter, cb_fn)
end

function MongoClientModule:delete_many(hash_code, db, coll, filter, cb_fn)
    return self.mongo_client:delete_many(hash_code, db, coll, filter, cb_fn)
end

function MongoClientModule:update_one(hash_code, db, coll, filter, doc, cb_fn, opt)
    assert(IsTable(filter))
    assert(IsTable(doc))
    assert(nil == cb_fn or IsFunction(cb_fn))
    assert(nil == opt or IsClassInstance(opt, MongoOptUpdate))
    local filter_str = rapidjson.encode(filter)
    local doc_str = rapidjson.encode(doc)
    local opt_str = nil == opt and "{}" or opt:to_json()
    return self.mongo_task_mgr_:update_one(hash_code, db, coll, filter_str, doc_str, opt_str, cb_fn)
end

function MongoClientModule:update_many(hash_code, db, coll, filter, doc, cb_fn, opt)
    return self.mongo_client:update_many(hash_code, db, coll, filter, doc, cb_fn, opt)
end

function MongoClientModule:find_one_and_delete(hash_code, db, coll, filter, cb_fn)
    return self.mongo_client:find_one_and_delete(hash_code, db, coll, filter, cb_fn)
end

function MongoClientModule:find_one_and_update(hash_code, db, coll, filter, doc, cb_fn, opt)
    return self.find_one_and_update(hash_code, db, coll, filter, doc, cb_fn, opt)
end

function MongoClientModule:find_one_and_replace(hash_code, db, coll, filter, doc, cb_fn)
    return self.find_one_and_replace(hash_code, db, coll, filter, doc, cb_fn)
end

function MongoClientModule:count_document(hash_code, db, coll, filter, cb_fn)
    return self.mongo_client:count_document(hash_code, db, coll, filter, cb_fn)
end



