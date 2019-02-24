
ServiceMain = ServiceMain or {}

g_http_service = nil
g_mongo_task_mgr = nil

local rapidjson = require('rapidjson')

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
    for i=1, 100 do
        g_mongo_task_mgr:insert_one(i, "test_2", "test_coll2", json_ctx, json_opt, mongo_task_cb)
        g_mongo_task_mgr:find_one(i, "test_2", "test_coll2", json_filter, json_opt, mongo_task_cb)
        g_mongo_task_mgr:delete_one(i, "test_2", "test_coll2", json_filter, json_opt, mongo_task_cb)
    end
    g_mongo_task_mgr:on_frame()
    return 0
end

function ServiceMain.start()
    local require_files = require("services.test_listen.service_files")
    for _, v in ipairs(require_files) do
        require(v)
    end

    RoleManager.start(3234)
    g_http_service = HttpService:new()
    g_http_service:start(20481)
    g_mongo_task_mgr = native.MongoTaskMgr:new()
    g_mongo_task_mgr:start(3, "192.168.56.101:27017", "test", "", "")
    -- RoleRobot.start(3234)
    native.timer_firm(xxx, 1000, 10000)
end