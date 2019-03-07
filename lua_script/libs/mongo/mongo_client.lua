
MongoClient = MongoClient or class("MongoClient")

function MongoClient:ctor(thread_num, hosts, auth_db, user_name, pwd)
    self.thread_num_ = thread_num
    self.hosts_ = hosts
    self.auth_db_ = auth_db
    self.user_name_ = user_name
    self.pwd_ = pwd
    self.mongo_task_mgr_ = native.MongoTaskMgr:new()
    self.timer_id_ = nil
end

function MongoClient:start()
    self:stop()
    self.timer_id_ = native.timer_firm(Functional.make_closure(MongoClient.on_tick, self), 100, -1)
    return self.mongo_task_mgr_:start(self.thread_num_, self.hosts_, self.auth_db_,
            self.user_name_, self.pwd_)
end

function MongoClient:on_tick()
    self.mongo_task_mgr_:on_frame()
end

function MongoClient:stop()
    self.mongo_task_mgr_:stop()
    if self.timer_id_ then
        native.timer_remove(self.timer_id_)
        self.timer_id_ = nil
    end
end


-- cb_fn = function(result_tb) end
-- opt = MongoOptFind
function MongoClient:find_one(hash_code, db, coll, filter, cb_fn, opt)
    assert(IsTable(filter))
    assert(nil == cb_fn or IsFunction(cb_fn))
    assert(nil == opt or IsClassInstance(opt, MongoOptFind))
    local filter_str = rapidjson.encode(filter)
    local opt_str = nil == opt and "{}" or opt:to_json()
    return self.mongo_task_mgr_:find_one(hash_code, db, coll, filter_str, opt_str, cb_fn)
end

function MongoClient:find_many(hash_code, db, coll, filter, cb_fn, opt)
    assert(IsTable(filter))
    assert(nil == cb_fn or IsFunction(cb_fn))
    assert(nil == opt or IsClassInstance(opt, MongoOptFind))
    local filter_str = rapidjson.encode(filter)
    local opt_str = nil == opt and "{}" or opt:to_json()
    return self.mongo_task_mgr_:find_many(hash_code, db, coll, filter_str, opt_str, cb_fn)
end

function MongoClient:insert_one(hash_code, db, coll, doc, cb_fn)
    assert(IsTable(doc))
    assert(nil == cb_fn or IsFunction(cb_fn))
    local doc_str = rapidjson.encode(doc)
    local opt_str = "{}"
    return self.mongo_task_mgr_:insert_one(hash_code, db, coll, doc_str, opt_str, cb_fn)
end

function MongoClient:insert_many(hash_code, db, coll, doc_array, cb_fn)
    assert(IsTable(doc_array))
    assert(nil == cb_fn or IsFunction(cb_fn))
    assert(nil == opt or IsClassInstance(opt, MongoOptFind))
    local docs_str = rapidjson.encode(doc_array)
    local opt_str = "{}"
    self.mongo_task_mgr_:insert_many(hash_code, db, coll, docs_str, opt_str, cb_fn)
end

function MongoClient:delete_one(hash_code, db, coll, filter, cb_fn)
    assert(IsTable(filter))
    assert(nil == cb_fn or IsFunction(cb_fn))
    local filter_str = rapidjson.encode(filter)
    local opt_str = "{}"
    return self.mongo_task_mgr_:delete_one(hash_code, db, coll, filter_str, opt_str, cb_fn)
end

function MongoClient:delete_many(hash_code, db, coll, filter, cb_fn)
    assert(IsTable(filter))
    assert(nil == cb_fn or IsFunction(cb_fn))
    local filter_str = rapidjson.encode(filter)
    local opt_str = "{}"
    return self.mongo_task_mgr_:delete_many(hash_code, db, coll, filter_str, opt_str, cb_fn)
end

function MongoClient:update_one(hash_code, db, coll, filter, doc, cb_fn, opt)
    assert(IsTable(filter))
    assert(IsTable(doc))
    assert(nil == cb_fn or IsFunction(cb_fn))
    assert(nil == opt or IsClassInstance(opt, MongoOptUpdate))
    local filter_str = rapidjson.encode(filter)
    local doc_str = rapidjson.encode(doc)
    local opt_str = nil == opt and "{}" or opt:to_json()
    return self.mongo_task_mgr_:update_one(hash_code, db, coll, filter_str, doc_str, opt_str, cb_fn)
end

function MongoClient:update_many(hash_code, db, coll, filter, doc, cb_fn, opt)
    assert(IsTable(filter))
    assert(IsTable(doc))
    assert(nil == cb_fn or IsFunction(cb_fn))
    assert(nil == opt or IsClassInstance(opt, MongoOptUpdate))
    local filter_str = rapidjson.encode(filter)
    local doc_str = rapidjson.encode(doc)
    local opt_str = nil == opt and "{}" or opt:to_json()
    return self.mongo_task_mgr_:update_many(hash_code, db, coll, filter_str, doc_str, opt_str, cb_fn)
end

function MongoClient:find_one_and_delete(hash_code, db, coll, filter, cb_fn)
    assert(IsTable(filter))
    assert(nil == cb_fn or IsFunction(cb_fn))
    local filter_str = rapidjson.encode(filter)
    local opt_str = "{}"
    return self.mongo_task_mgr_:replace_one(hash_code, db, coll, filter_str, opt_str, cb_fn)
end

function MongoClient:find_one_and_update(hash_code, db, coll, filter, doc, cb_fn, opt)
    assert(IsTable(filter))
    assert(IsTable(doc))
    assert(nil == cb_fn or IsFunction(cb_fn))
    assert(nil == opt or IsClassInstance(opt, MongoOptFindOneAndUpdate))
    local filter_str = rapidjson.encode(filter)
    local doc_str = rapidjson.encode(doc)
    local opt_str = nil == opt and "{}" or opt:to_json()
    return self.mongo_task_mgr_:find_one_and_update(hash_code, db, coll, filter_str, doc_str, opt_str, cb_fn)
end

function MongoClient:find_one_and_replace(hash_code, db, coll, filter, doc, cb_fn)
    assert(IsTable(filter))
    assert(IsTable(doc))
    assert(nil == cb_fn or IsFunction(cb_fn))
    local filter_str = rapidjson.encode(filter)
    local doc_str = rapidjson.encode(doc)
    local opt_str = "{}"
    return self.mongo_task_mgr_:find_one_and_replace(hash_code, db, coll, filter_str, doc_str, opt_str, cb_fn)
end

function MongoClient:count_document(hash_code, db, coll, filter, cb_fn)
    assert(IsTable(filter))
    assert(nil == cb_fn or IsFunction(cb_fn))
    local filter_str = rapidjson.encode(filter)
    local opt_str = "{}"
    return self.mongo_task_mgr_:count_document(hash_code, db, coll, filter_str, opt_str, cb_fn)
end


