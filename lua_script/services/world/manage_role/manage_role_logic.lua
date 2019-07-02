
ManageRoleLogic = ManageRoleLogic or class("ManageRoleLogic", ServiceLogic)

function ManageRoleLogic:ctor(logic_mgr, logic_name)
    ManageRoleLogic.super.ctor(self, logic_mgr, logic_name)
    self.rpc_mgr = self.service.rpc_mgr
    self.db_client = self.service.db_client
    self.query_db = self.service.query_db
    self.query_coll = "role"
    self.last_session_id = 0
    self.session_id_to_role = {} -- 辅
    self.role_id_to_role = {} -- 主
end

function ManageRoleLogic:init()
    ManageRoleLogic.super.init(self)

    local rpc_process_fns_map = {
        [WorldRpcFn.get_role_digest] = self.get_role_digest,
        [WorldRpcFn.create_role] = self.create_role,
        [WorldRpcFn.launch_role] = self.launch_role,
        [WorldRpcFn.client_quit] = self.client_quit,
    }

    local rpc_co_process_fns_map = {

    }
    for fn_name, fn in pairs(rpc_process_fns_map) do
        self.rpc_mgr:set_req_msg_process_fn(fn_name, Functional.make_closure(fn, self))
    end
    for fn_name, fn in pairs(rpc_co_process_fns_map) do
        self.rpc_mgr:set_req_msg_coroutine_process_fn(fn_name, Functional.make_closure(fn, self))
    end
end

function ManageRoleLogic:next_session_id()
    self.last_session_id = self.last_session_id + 1
    return self.last_session_id
end

function ManageRoleLogic:start()
    ManageRoleLogic.super.start(self)
end

function ManageRoleLogic:stop()
    ManageRoleLogic.super.stop(self)
end

function ManageRoleLogic:get_role_digest(rpc_rsp, user_id, role_id)
    log_debug("process_fns.get_role_digest %s %s", user_id, role_id)

    local find_opt = MongoOptFind:new()
    find_opt:set_max_time(5 * 1000)
    local filter = {}
    filter.user_id = user_id
    if role_id > 0 then
        filter.role_id = role_id
    end
    self.db_client:find_many(1, self.query_db, self.query_coll, filter, function(db_ret)
        log_debug("get_role_digest db_ret %s", db_ret)
        if 0 == db_ret.error_num then
            local ret = {}
            for _, v in pairs(db_ret.val) do
                table.insert(ret, { role_id=v.role_id })
            end
            rpc_rsp:respone(ret)
            return
        end
        rpc_rsp:report_error(string.format("error_num:%s, error_msg:%s", db_ret.error_num, db_ret.error_msg))
    end, find_opt)
end

function ManageRoleLogic:create_role(rpc_rsp, user_id)
    log_debug("ManageRoleLogic:create_role %s", user_id)
    if not user_id then
        rpc_rsp:report_error("user_id is nil")
        return
    end
    local role_id = self.service.db_uuid:apply(Service_Const.role_id)
    if not role_id then
        rpc_rsp:report_error("apply role id fail")
        return
    end
    local doc ={
        user_id = user_id,
        role_id = role_id,
    }
    local filter = {}
    filter.user_id = user_id
    self.db_client:count_document(1, self.query_db, self.query_coll, filter, function(db_ret)
        local Max_Role_Count = 3
        if 0 == db_ret.error_num and db_ret.matched_count < Max_Role_Count then
            self.db_client:insert_one(1, self.query_db, self.query_coll, doc, function(db_ret)
                log_debug("create role db_ret %s", db_ret)
                if 0 == db_ret.error_num then
                    rpc_rsp:respone(doc.role_id)
                else
                    rpc_rsp:report_error(string.format("error_num:%s, error_msg:%s", db_ret.error_num, db_ret.error_msg))
                end
            end)
        else
            rpc_rsp:report_error(string.format("already create role %s/%s", db_ret.matched_count, Max_Role_Count))
        end
    end)
end

ManageRoleLogic._Launch_Role_Error = {
    no_valid_game_service = 1,
    launch_fail = 2,
    repeat_launch = 3,
    another_launch = 4,
    unknown = 5,
}

function ManageRoleLogic:launch_role(rpc_rsp, role_id, client_netid)
    log_debug("world ManageRoleLogic:launch_role %s", role_id)
    local role = self.role_id_to_role[role_id]
    if role then
        if Role_State.released == self.state or Role_State.inited == self.state then
            assert(false, string.format("should not happend %s", role))
            return
        end
        local old_session = role.session_id

        if Role_State.idle == role.state then
            role.session_id = self:next_session_id()
            rpc_rsp:respone(Error_None, role.game_client.remote_host, role.session_id)
        end
        if Role_State.using == role.state then
            if role.gate_client.remote_host == rpc_rsp.from_host or client_netid == role.client_netid then
                rpc_rsp:respone(_Launch_Role_Error.repeat_launch)
            else
                role.gate_client:call(nil, GateRpcFn.kick_client, role.client_netid) -- 通知gate踢人
                role.session_id = self:next_session_id()
                rpc_rsp:respone(Error_None, role.game_client.remote_host, role.session_id)
            end
        end
        if Role_State.launch == role.state then
            if role.gate_client.remote_host == rpc_rsp.from_host or client_netid == role.client_netid then
                rpc_rsp:respone(_Launch_Role_Error.repeat_launch)
            else
                -- 通知上一个client被顶号
                role.cached_launch_rsp:respone(_Launch_Role_Error.another_launch)
                role.cached_launch_rsp = rpc_rsp
                role.session_id = self:next_session_id()
                self.service.rpc_mgr:call(
                        Functional.make_closure(self._rpc_rsp_launch_role, self, role.session_id, role_id),
                        service_info.key, GameRpcFn.launch_role, role_id)
            end
        end

        role.gate_client = self.service:create_rpc_client(rpc_rsp.from_host)
        role.client_netid = client_netid
        self.session_id_to_role[role.session_id] = role
        if old_session ~= role.session_id then
            self.session_id_to_role[old_session] = nil
        end
    else
        local service_info = self.service.zone_net:rand_service(Service_Const.Game)
        if not service_info then
            rpc_rsp:respone(_Launch_Role_Error.no_valid_game_service)
        else
            role = {}
            role.role_id = role_id
            role.session_id = self:next_session_id()
            role.gate_client = self.service:create_rpc_client(rpc_rsp.from_host)
            role.client_netid = client_netid
            role.game_client = self.service:create_rpc_client(service_info.key)
            role.state = Role_State.inited
            role.cached_launch_rsp = rpc_rsp
            self.role_id_to_role[role.role_id] = role
            self.session_id_to_role[role.session_id] = role
            self.service.rpc_mgr:call(
                    Functional.make_closure(self._rpc_rsp_launch_role, self, role.session_id, role_id),
                    service_info.key, GameRpcFn.launch_role, role_id)
            role.state = Role_State.launch
        end
    end
end

function ManageRoleLogic:_rpc_rsp_launch_role(session_id, role_id, rpc_error_num, launch_error_num)
    log_debug("xxxxxxxxxxxxxxxx ManageRoleLogic:_rpc_rsp_launch_role %s %s", rpc_error_num, launch_error_num)
    local role = self.role_id_to_role[role_id]
    if not role then
        return -- 可能客户端掉线执行了client_quit,直接返回就好
    end
    if role.session_id ~= session_id then
        return -- 应该是被顶号了
    end
    if Role_State.launch ~= role.state then
        log_error("launch role error: role state is not in Role_State.launch, current state is %s", role.state)
        -- todo: 发生了意想不到的错误，让客户端断开连接,让game登出角色，清理role数据
        role.cached_launch_rsp:respone(_Launch_Role_Error.unknown)
        role.gate_client:call(nil, GateRpcFn.kick_client, role.client_netid) -- 通知gate踢人
        -- 通知game登出角色，
        -- 清理role数据
        return
    end
    if Rpc_Error.None ~= rpc_error_num or 0 ~= launch_error_num then
        role.cached_launch_rsp:respone(_Launch_Role_Error.launch_fail)
    else
        role.cached_launch_rsp:respone(Error_None, role.game_client.remote_host, role.session_id)
    end
    role.cached_launch_rsp = nil
end

function ManageRoleLogic:client_quit(rpc_rsp, role_id)

end
