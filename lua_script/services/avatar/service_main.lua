
for _, v in ipairs(require("services.avatar.avatar_service_files")) do
    require(v)
end

function create_service_main()
    return AvatarService:new()
end

AvatarService = AvatarService or class("AvatarService", GameServiceBase)

function AvatarService:ctor()
    AvatarService.super.ctor(self)
    self.mongo_db = nil
end

function AvatarService:setup_modules()
    AvatarService.super.setup_modules(self)
    self.mongo_db = MongoClientModule:new(self.module_mgr, "mongo_db")
    self.module_mgr:add_module(self.mongo_db)
    self.mongo_db:init("124.156.106.95:27017", "admin", "lxl", "xiaolzz")
end

function AvatarService:new_zone_net_msg_handler()
    local msg_handler = AvatarZoneServiceMsgHandler:new()
    msg_handler:init()
    return msg_handler
end

function AvatarService:new_zone_net_rpc_mgr()
    local rpc_mgr = ZoneServiceRpcMgr:new()

    local co_fn = function(rsp, ...)
        rsp:add_delay_execute(function ()
            log_debug("reach delay execute fn")
        end)
        return Rpc_Const.Action_Return_Result, ...
    end
    rpc_mgr:set_req_msg_coroutine_process_fn("hello_world", co_fn)

    local simple_rsp_fn = function(rsp, ...)
        rsp:respone(...)
    end
    rpc_mgr:set_req_msg_process_fn("simple_rsp", simple_rsp_fn)

    return rpc_mgr
end

function test_mongo_client(self)
    local mongo_task_cb = function (result_json_str)
        -- log_debug("mongo_task_cb %s", result_json_str)
    end

    local tb_filter = {}
    local tb_ctx = { a=100, b=101, c=122 }

    local find_opt = MongoOptFind:new()
    find_opt:set_max_time(10 * 1000)
    find_opt:set_projection({a=true, c=true})
    find_opt:set_limit(2)
    find_opt:set_skip(1)

    for i=1, 1 do
        self.mongo_db:insert_one(i, "test_2", "test_coll2", tb_ctx, mongo_task_cb)
        self.mongo_db:insert_one(i, "test_2", "test_coll2", tb_ctx, mongo_task_cb)
        self.mongo_db:insert_one(i, "test_2", "test_coll2", tb_ctx, mongo_task_cb)
        self.mongo_db:insert_one(i, "test_2", "test_coll2", tb_ctx, mongo_task_cb)
        self.mongo_db:insert_one(i, "test_2", "test_coll2", tb_ctx, mongo_task_cb)
        self.mongo_db:insert_one(i, "test_2", "test_coll2", tb_ctx, mongo_task_cb)
        self.mongo_db:find_one(i, "test_2", "test_coll2", tb_filter, mongo_task_cb, find_opt)
        self.mongo_db:find_many(i, "test_2", "test_coll2", tb_filter, mongo_task_cb, find_opt)
        self.mongo_db:delete_many(i, "test_2", "test_coll2", tb_filter, mongo_task_cb)
    end
end

function AvatarService:on_frame()
    AvatarService.super.on_frame(self)
    test_mongo_client(self)
end
