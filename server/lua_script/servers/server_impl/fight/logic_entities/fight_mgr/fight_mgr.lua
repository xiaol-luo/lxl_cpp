
---@class FightMgr:GameLogicEntity
FightMgr = FightMgr or class("FightMgr", GameLogicEntity)

function FightMgr:_on_init()
    FightMgr.super._on_init(self)
    ---@type MatchServiceMgr
    self.server = self.server
end

function FightMgr:_on_start()
    FightMgr.super._on_start(self)
    -- self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.create_role.query_roles, Functional.make_closure(self._handle_remote_call_query_roles, self))
    -- self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.create_role.create_role, Functional.make_closure(self._handle_remote_call_create_role, self))
end

function FightMgr:_on_stop()
    FightMgr.super._on_stop(self)
    self._rpc_svc_proxy:clear_remote_call()
end

function FightMgr:_on_release()
    FightMgr.super._on_release(self)
end

function FightMgr:_on_update()
    -- log_print("FightMgr:_on_update")
end


--- rpc函数

function RoomMgr:_on_map_remote_call_handle_fns()
    self._method_name_to_remote_call_handle_fns[Rpc.room.setup_room] = Functional.make_closure(self._on_rpc_setup_room, self)
end

---@param rpc_rsp RpcRsp
function FightMgr:_handle_remote_call_create_role(rpc_rsp, user_id)
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
    self._db_client:count_document(user_id, self.server.zone_name, Const.mongo.collection_name.role, { user_id = user_id }, function(db_ret)
        if 0 == db_ret.error_num then
            if db_ret.matched_count < Const.role_count_per_user then
                self._db_client:insert_one(user_id, self.server.zone_name, Const.mongo.collection_name.role, doc, function(db_ret)
                    if 0 == db_ret.error_num then
                        rpc_rsp:response(Error_None, doc.role_id)
                    else
                        rpc_rsp:response(db_ret.error_num, string.format("insert role fail, error_num is %s, error_msg is %s", db_ret.error_num, db_ret.error_msg))
                    end
                end)
            else
                rpc_rsp:response(20, string.format("user has role num is %s, more than %s", db_ret.matched_count, Const.role_count_per_user))
            end
        else
            rpc_rsp:response(db_ret.error_num, string.format("query role count fail, error_num is %s, error_msg is %s", db_ret.error_num, db_ret.error_msg))
        end
    end)
end

---@param rpc_rsp RpcRsp
function FightMgr:_handle_remote_call_query_roles(rpc_rsp, user_id, role_id)
    -- log_print("FightMgr:_handle_remote_call_query_roles",  user_id, role_id)
    local find_opt = MongoOptFind:new()
    find_opt:set_max_time(5 * 1000)
    local filter = {}
    filter.user_id = user_id
    if role_id and role_id > 0 then
        filter.role_id = role_id
    end
    self._db_client:find_many(user_id, self.server.zone_name, Const.mongo.collection_name.role, filter, function(db_ret)
        if 0 == db_ret.error_num then
            local ret = {}
            for _, v in pairs(db_ret.val) do
                table.insert(ret, { role_id = v.role_id })
            end
            rpc_rsp:response(Error_None, ret)
        else
            rpc_rsp:report_error(db_ret.error_num, string.format("error_num:%s, error_msg:%s", db_ret.error_num, db_ret.error_msg))
        end
    end, find_opt)
end

