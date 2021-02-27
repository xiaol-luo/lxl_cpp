
---@class AuthServiceMgr: ServiceMgrBase
---@field logics AuthLogicService
---@field server AuthServer
AuthServiceMgr = class("AuthServiceMgr", ServiceMgrBase)

function AuthServiceMgr:ctor(server)
    AuthServiceMgr.super.ctor(self, server, CustomServiceHelpFn.setup_http_service)
end

function AuthServiceMgr:_on_init()
    do
        local svc = DBUuidService:new(self, Service_Name.db_uuid)
        local mg_setting = self.server.mongo_setting_uuid
        svc:init(mg_setting.host, mg_setting.auth_db, mg_setting.user, mg_setting.pwd,
                DB_Uuid_Const.query_db, DB_Uuid_Const.query_coll, { [DB_Uuid_Names.user_id]=true })
        self:add_service(svc)
    end

    do
        local svc = AuthLogicService:new(self, Service_Name.logics)
        svc:init()
        self:add_service(svc)
    end

    return true
end

function AuthServiceMgr:on_frame()
    AuthServiceMgr.super.on_frame(self)

    local fn_set = native.LockStepSetLuaObject.new()

    local x1000 = native.FixNumber.new(1000)
    local x100 = native.FixNumber.new(100)
    local x3 = native.FixNumber.make(3)

    -- fn_set:insert(1)
    local aa = "xxx"
    fn_set:insert(aa)
    fn_set:insert(aa)
    -- fn_set:insert(x1000)
    -- fn_set:insert(x100)


    for k, v in pairs(fn_set) do
        print("in for ", k, v)
    end
    print("-------------------------------")
--[[
    log_print("aa ", x1000 + x100, x1000 * x100, x1000 / x100, x1000 % x3);
    log_print("bb ", x100 ^ x3, x1000 > x100, x1000 < x100, x1000 >= x100, x1000 == x100, x1000 <= x100);
    log_print("cc", native.FixNumber.sin(x1000))
--]]

end