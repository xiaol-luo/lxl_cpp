
ServiceMain = ServiceMain or {}

g_http_service = nil
g_mongo_task_mgr = nil
g_mongo_client = nil

function mongo_task_cb(result_json_str)
    local ret_tb = rapidjson.decode(result_json_str)
    if ret_tb["val"] then
        ret_tb["val_tb"] = rapidjson.decode(ret_tb["val"])
    end
    log_debug("mongo_task_cb %s", ret_tb)
end

function xxx()
    local tb_filter = {}
    local tb_ctx = { a=100 }
    local tb_opt = {}
    local json_filter = rapidjson.encode(tb_filter)
    local json_ctx = rapidjson.encode(tb_ctx)
    local json_opt = rapidjson.encode(tb_opt)
    for i=1, 2 do
        g_mongo_task_mgr:insert_one(i, "test_2", "test_coll2", json_ctx, json_opt, mongo_task_cb)
        g_mongo_task_mgr:insert_one(i, "test_2", "test_coll2", json_ctx, json_opt, mongo_task_cb)
        g_mongo_task_mgr:find_one(i, "test_2", "test_coll2", json_filter, json_opt, mongo_task_cb)
        g_mongo_task_mgr:find_many(i, "test_2", "test_coll2", json_filter, json_opt, mongo_task_cb)
        g_mongo_task_mgr:delete_many(i, "test_2", "test_coll2", json_filter, json_opt, mongo_task_cb)
        -- g_mongo_task_mgr:delete_one(i, "test_2", "test_coll2", json_filter, json_opt, mongo_task_cb)
        -- g_mongo_task_mgr:delete_one(i, "test_2", "test_coll2", json_filter, json_opt, mongo_task_cb)
    end
    g_mongo_task_mgr:on_frame()
    return 0
end

function yyy()
    local tb_filter = {}
    local tb_ctx = { a=100, b=101, c=122 }
    local tb_opt = {}

    local find_opt = MongoOptFind:new()
    find_opt:set_max_time(10 * 1000)
    find_opt:set_projection({a=true, c=true})
    find_opt:set_limit(2)
    find_opt:set_skip(1)

    -- log_debug("find_opt %s",string.toprint(find_opt))
    -- log_debug("MongoOptFind %s",string.toprint(MongoOptFind))

    for i=1, 1 do
        g_mongo_client:insert_one(i, "test_2", "test_coll2", tb_ctx, mongo_task_cb)
        g_mongo_client:insert_one(i, "test_2", "test_coll2", tb_ctx, mongo_task_cb)
        g_mongo_client:insert_one(i, "test_2", "test_coll2", tb_ctx, mongo_task_cb)
        g_mongo_client:insert_one(i, "test_2", "test_coll2", tb_ctx, mongo_task_cb)
        g_mongo_client:insert_one(i, "test_2", "test_coll2", tb_ctx, mongo_task_cb)
        g_mongo_client:insert_one(i, "test_2", "test_coll2", tb_ctx, mongo_task_cb)
        g_mongo_client:find_one(i, "test_2", "test_coll2", tb_filter, mongo_task_cb, find_opt)
        g_mongo_client:find_many(i, "test_2", "test_coll2", tb_filter, mongo_task_cb, find_opt)
        g_mongo_client:delete_many(i, "test_2", "test_coll2", tb_filter, mongo_task_cb)
    end
end

function ServiceMain.start()
    local require_files = require("services.test_listen.service_files")
    for _, v in ipairs(require_files) do
        require(v)
    end

    log_debug("xxxxxxxxxxxxxxxxx %s %s %s", native.mongo_opt_field_name.max_time, native.mongo_opt_field_name.projection, native.mongo_opt_field_name.upsert)

    RoleManager.start(3234)
    g_http_service = HttpService:new()
    g_http_service:start(20481)
    g_mongo_task_mgr = native.MongoTaskMgr:new()
    -- g_mongo_task_mgr:start(3, "124.156.106.95:27017", "admin", "lxl", "xiaolzz")
    -- RoleRobot.start(3234)
    -- native.timer_firm(xxx, 1000, 10000)
    g_mongo_client = MongoClient:new(3, "124.156.106.95:27017", "admin", "lxl", "xiaolzz")
    g_mongo_client:start()
    native.timer_firm(yyy, 1000, 10000)
end