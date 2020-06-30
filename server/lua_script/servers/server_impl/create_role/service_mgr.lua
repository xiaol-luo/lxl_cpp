
---@class ServiceMgr: ServiceMgrBase
ServiceMgr = class("ServiceMgr", ServiceMgrBase)

function ServiceMgr:ctor(server)
    ServiceMgr.super.ctor(self, server)
end

function ServiceMgr:_on_init()

    local db_uuid = DBUuidService:new(self, Service_Name.db_uuid)
    ---@type CreateRoleServer
    local server = self.server
    local mg_setting_uuid = server.mongo_setting_uuid
    db_uuid:init(mg_setting_uuid.host, mg_setting_uuid.auth_db, mg_setting_uuid.user, mg_setting_uuid.pwd,
            DB_Uuid_Const.query_db, DB_Uuid_Const.query_coll, { [DB_Uuid_Names.role_id]=true })
    self:add_service(db_uuid)

    return true
end
