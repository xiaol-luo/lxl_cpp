
---@class CreateRoleServiceMgr: ServiceMgrBase
CreateRoleServiceMgr = class("CreateRoleServiceMgr", ServiceMgrBase)

function CreateRoleServiceMgr:ctor(server)
    CreateRoleServiceMgr.super.ctor(self, server)
end

function CreateRoleServiceMgr:_on_init()

    local db_uuid = DBUuidService:new(self, Service_Name.db_uuid)
    ---@type CreateRoleServer
    local server = self.server
    local mg_setting_uuid = server.mongo_setting_uuid
    db_uuid:init(mg_setting_uuid.host, mg_setting_uuid.auth_db, mg_setting_uuid.user, mg_setting_uuid.pwd,
            DB_Uuid_Const.query_db, DB_Uuid_Const.query_coll, { [DB_Uuid_Names.role_id]=true })
    self:add_service(db_uuid)

    local logic_svc = CreateRoleLogicService:new(self, Service_Name.logics)
    logic_svc:init()
    self:add_service(logic_svc)

    return true
end
