
MongoClient = MongoClient or class("MongoClient")

function MongoClient:ctor(thread_num, hosts, auth_db, user_name, pwd)
    self.thread_num_ = thread_num
    self.hosts_ = hosts
    self.auth_db_ = auth_db
    self.user_name_ = user_name
    self.pwd_ = pwd
    self.mongo_task_mgr_ = native.MongoTaskMgr:new()
    self.timer_proxy = TimerProxy:new()
end

function MongoClient:start()
    self:stop()
    local ret = self.mongo_task_mgr_:start(self.thread_num_, self.hosts_, self.auth_db_, self.user_name_, self.pwd_)
    if ret then
        self.timer_proxy:firm(Functional.make_closure(self.on_tick, self), 200, Forever_Execute_Timer)
    end
    return ret
end

function MongoClient:on_tick()
    self.timer_proxy:release_all()
    self.mongo_task_mgr_:on_frame()
end

function MongoClient:stop()
    self.mongo_task_mgr_:stop()
end

local process_mongo_cb = function(cb_fn, ret_json_str)
    if cb_fn then
        local ret = rapidjson.decode(ret_json_str)
        local val_str = ret["val"]
        if val_str then
            ret["val"] = rapidjson.decode(val_str)
        end
        safe_call(cb_fn, ret)
    end
end
local wrap_mongo_cb = function(cb_fn)
    local ret = nil
    if cb_fn then
        ret = Functional.make_closure(process_mongo_cb, cb_fn)
    end
    return ret
end

-- cb_fn = function(result_tb) end
-- opt = MongoOptFind
function MongoClient:find_one(hash_code, db, coll, filter, cb_fn, opt)
    assert(is_table(filter))
    assert(nil == cb_fn or is_function(cb_fn))
    assert(nil == opt or is_class_instance(opt, MongoOptFind))
    local filter_str = rapidjson.encode(filter)
    local opt_str = nil == opt and "{}" or opt:to_json()
    return self.mongo_task_mgr_:find_one(hash_code, db, coll, filter_str, opt_str, wrap_mongo_cb(cb_fn))
end

function MongoClient:find_many(hash_code, db, coll, filter, cb_fn, opt)
    assert(is_table(filter))
    assert(nil == cb_fn or is_function(cb_fn))
    assert(nil == opt or is_class_instance(opt, MongoOptFind))
    local filter_str = rapidjson.encode(filter)
    local opt_str = nil == opt and "{}" or opt:to_json()
    return self.mongo_task_mgr_:find_many(hash_code, db, coll, filter_str, opt_str, wrap_mongo_cb(cb_fn))
end

function MongoClient:insert_one(hash_code, db, coll, doc, cb_fn)
    assert(is_table(doc))
    assert(nil == cb_fn or is_function(cb_fn))
    local doc_str = rapidjson.encode(doc)
    local opt_str = "{}"
    return self.mongo_task_mgr_:insert_one(hash_code, db, coll, doc_str, opt_str, wrap_mongo_cb(cb_fn))
end

function MongoClient:insert_many(hash_code, db, coll, doc_array, cb_fn)
    assert(is_table(doc_array))
    assert(nil == cb_fn or is_function(cb_fn))
    assert(nil == opt or is_class_instance(opt, MongoOptFind))
    local docs_str = rapidjson.encode(doc_array)
    local opt_str = "{}"
    self.mongo_task_mgr_:insert_many(hash_code, db, coll, docs_str, opt_str, wrap_mongo_cb(cb_fn))
end

function MongoClient:delete_one(hash_code, db, coll, filter, cb_fn)
    assert(is_table(filter))
    assert(nil == cb_fn or is_function(cb_fn))
    local filter_str = rapidjson.encode(filter)
    local opt_str = "{}"
    return self.mongo_task_mgr_:delete_one(hash_code, db, coll, filter_str, opt_str, wrap_mongo_cb(cb_fn))
end

function MongoClient:delete_many(hash_code, db, coll, filter, cb_fn)
    assert(is_table(filter))
    assert(nil == cb_fn or is_function(cb_fn))
    local filter_str = rapidjson.encode(filter)
    local opt_str = "{}"
    return self.mongo_task_mgr_:delete_many(hash_code, db, coll, filter_str, opt_str, wrap_mongo_cb(cb_fn))
end

function MongoClient:update_one(hash_code, db, coll, filter, doc, cb_fn, opt)
    assert(is_table(filter))
    assert(is_table(doc))
    assert(nil == cb_fn or is_function(cb_fn))
    assert(nil == opt or is_class_instance(opt, MongoOptUpdate))
    local filter_str = rapidjson.encode(filter)
    local doc_str = rapidjson.encode(doc)
    local opt_str = nil == opt and "{}" or opt:to_json()
    return self.mongo_task_mgr_:update_one(hash_code, db, coll, filter_str, doc_str, opt_str, wrap_mongo_cb(cb_fn))
end

function MongoClient:update_many(hash_code, db, coll, filter, doc, cb_fn, opt)
    assert(is_table(filter))
    assert(is_table(doc))
    assert(nil == cb_fn or is_function(cb_fn))
    assert(nil == opt or is_class_instance(opt, MongoOptUpdate))
    local filter_str = rapidjson.encode(filter)
    local doc_str = rapidjson.encode(doc)
    local opt_str = nil == opt and "{}" or opt:to_json()
    return self.mongo_task_mgr_:update_many(hash_code, db, coll, filter_str, doc_str, opt_str, wrap_mongo_cb(cb_fn))
end

function MongoClient:find_one_and_delete(hash_code, db, coll, filter, cb_fn)
    assert(is_table(filter))
    assert(nil == cb_fn or is_function(cb_fn))
    local filter_str = rapidjson.encode(filter)
    local opt_str = "{}"
    return self.mongo_task_mgr_:replace_one(hash_code, db, coll, filter_str, opt_str, wrap_mongo_cb(cb_fn))
end

function MongoClient:find_one_and_update(hash_code, db, coll, filter, doc, cb_fn, opt)
    assert(is_table(filter))
    assert(is_table(doc))
    assert(nil == cb_fn or is_function(cb_fn))
    assert(nil == opt or is_class_instance(opt, MongoOptFindOneAndUpdate))
    local filter_str = rapidjson.encode(filter)
    local doc_str = rapidjson.encode(doc)
    local opt_str = nil == opt and "{}" or opt:to_json()
    return self.mongo_task_mgr_:find_one_and_update(hash_code, db, coll, filter_str, doc_str, opt_str, wrap_mongo_cb(cb_fn))
end

function MongoClient:find_one_and_replace(hash_code, db, coll, filter, doc, cb_fn)
    assert(is_table(filter))
    assert(is_table(doc))
    assert(nil == cb_fn or is_function(cb_fn))
    local filter_str = rapidjson.encode(filter)
    local doc_str = rapidjson.encode(doc)
    local opt_str = "{}"
    return self.mongo_task_mgr_:find_one_and_replace(hash_code, db, coll, filter_str, doc_str, opt_str, wrap_mongo_cb(cb_fn))
end

function MongoClient:count_document(hash_code, db, coll, filter, cb_fn)
    assert(is_table(filter))
    assert(nil == cb_fn or is_function(cb_fn))
    local filter_str = rapidjson.encode(filter)
    local opt_str = "{}"
    return self.mongo_task_mgr_:count_document(hash_code, db, coll, filter_str, opt_str, wrap_mongo_cb(cb_fn))
end

function MongoClient:co_find_one(hash_code, db, coll, filter, opt)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    self:find_one(hash_code, db, coll, filter, new_coroutine_callback(co), opt)
    return ex_coroutine_yield(co)
end

function MongoClient:co_insert_one(hash_code, db, coll, doc)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    self:insert_one(hash_code, db, coll, doc, new_coroutine_callback(co))
    return ex_coroutine_yield(co)
end

function MongoClient:co_find_many(hash_code, db, coll, filter, opt)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    self:find_many(hash_code, db, coll, filter, new_coroutine_callback(co), opt)
    return ex_coroutine_yield(co)
end

function MongoClient:co_insert_many(hash_code, db, coll, doc_array)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    self:insert_many(hash_code, db, coll, doc_array, new_coroutine_callback(co))
    return ex_coroutine_yield(co)
end

function MongoClient:co_delete_one(hash_code, db, coll, filter)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    self:delete_one(hash_code, db, coll, filter, new_coroutine_callback(co))
    return ex_coroutine_yield(co)
end

function MongoClient:co_delete_many(hash_code, db, coll, filter)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    self:delete_many(hash_code, db, coll, filter, new_coroutine_callback(co))
    return ex_coroutine_yield(co)
end

function MongoClient:co_update_one(hash_code, db, coll, filter, doc, opt)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    self:update_one(hash_code, db, coll, filter, doc, new_coroutine_callback(co), opt)
    return ex_coroutine_yield(co)
end

function MongoClient:co_update_many(hash_code, db, coll, filter, doc, opt)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    self:update_many(hash_code, db, coll, filter, doc, new_coroutine_callback(co), opt)
    return ex_coroutine_yield(co)
end

function MongoClient:co_find_one_and_delete(hash_code, db, coll, filter)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    self:find_one_and_delete(hash_code, db, coll, filter, new_coroutine_callback(co))
    return ex_coroutine_yield(co)
end

function MongoClient:co_find_one_and_update(hash_code, db, coll, filter, doc, opt)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    self:find_one_and_update(hash_code, db, coll, filter, doc, new_coroutine_callback(co), opt)
    return ex_coroutine_yield(co)
end

function MongoClient:co_find_one_and_replace(hash_code, db, coll, filter, doc)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    self:find_one_and_replace(hash_code, db, coll, filter, doc, new_coroutine_callback(co))
    return ex_coroutine_yield(co)
end

function MongoClient:co_count_document(hash_code, db, coll, filter)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    self:count_document(hash_code, db, coll, filter, new_coroutine_callback(co))
    return ex_coroutine_yield(co)
end




