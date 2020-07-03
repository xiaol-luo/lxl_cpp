
---@class CreateRoleLogic:LogicEntity
CreateRoleLogic = CreateRoleLogic or class("CreateRoleLogic", LogicEntity)

function CreateRoleLogic:_on_init()
    CreateRoleLogic.super._on_init(self)
    ---@type CreateRoleServiceMgr
    self.server = self.server
    ---@type MongoServerConfig
    local db_setting = self.server.mongo_setting_game
    self._db_client = MongoClient:new(db_setting.thread_num, db_setting.host, db_setting.auth_db,  db_setting.user, db_setting.pwd)
end

function CreateRoleLogic:_on_start()
    CreateRoleLogic.super._on_start(self)
    if not self._db_client:start() then
        self:set_error(-1, "CreateRoleLogic:_on_start start mongo client fail")
        return
    end
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.create_role.method.query_roles, Functional.make_closure(self._handle_remote_call_query_roles, self))
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.create_role.method.create_role, Functional.make_closure(self._handle_remote_call_create_role, self))
end

function CreateRoleLogic:_on_stop()
    CreateRoleLogic.super._on_stop(self)
    self._rpc_svc_proxy:clear_remote_call()
end

function CreateRoleLogic:_on_release()
    CreateRoleLogic.super._on_release(self)
end

function CreateRoleLogic:_on_update()
    -- log_print("CreateRoleLogic:_on_update")
end

---@param rpc_rsp RpcRsp
function CreateRoleLogic:_handle_remote_call_query_roles(rpc_rsp, user_id)
    if not user_id then
        rpc_rsp:report_error("user_id is nil")
        return
    end
    local new_role_id = self.server.db_uuid:apply(DB_Uuid_Names.role_id)
    if not new_role_id then
        rpc_rsp:report_error("apply new role id fail")
        return
    end
    local doc = {
        user_id = user_id,
        role_id = new_role_id,
    }

    --
    self._db_client:count_document(user_id, self.server.zone_name, Const.mongo.collection_name.user, { user_id = user_id }, function()
        
    end)

    rsp:respone()
    log_print("CreateRoleLogic:_handle_remote_call_query_roles")
end

---@param rpc_rsp RpcRsp
function CreateRoleLogic:_handle_remote_call_create_role(rpc_rsp)
    log_print("CreateRoleLogic:_handle_remote_call_create_role")
    rsp:respone()
end

