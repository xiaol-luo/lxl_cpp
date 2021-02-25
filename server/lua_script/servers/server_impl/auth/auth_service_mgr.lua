
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
--[[
    local x1000 = native.FixNumber.new("1000")
    local x100 = native.FixNumber.new(100)
    log_print("aa ", tostring(x1000), x100, native.FixNumber.make(300), native.FixNumber.make("400"));
    --]]
end