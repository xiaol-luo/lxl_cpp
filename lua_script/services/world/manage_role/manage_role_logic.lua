
ManageRoleLogic = ManageRoleLogic or class("ManageRoleLogic", ServiceLogic)

function ManageRoleLogic:ctor(logic_mgr, logic_name)
    ManageRoleLogic.super.ctor(self, logic_mgr, logic_name)
    self.rpc_mgr = self.service.rpc_mgr
    self.db_client = self.service.db_client
    self.query_db = self.service.query_db
    self.query_coll = "role"
    self.last_session_id = 0
    self.last_opera_id = 0
    self.session_id_to_role = {} -- 辅
    self.role_id_to_role = {} -- 主
    self.timer_proxy = nil
end

function ManageRoleLogic:init()
    ManageRoleLogic.super.init(self)
    self.timer_proxy = TimerProxy:new()

    local rpc_process_fns_map = {
        [WorldRpcFn.get_role_digest] = self.get_role_digest,
        [WorldRpcFn.create_role] = self.create_role,
        [WorldRpcFn.launch_role] = self.launch_role,
        [WorldRpcFn.client_quit] = self.client_quit,
        [WorldRpcFn.logout_role] = self.logout_role,
        [WorldRpcFn.reconnect_role] = self.reconnect_role,
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

function ManageRoleLogic:next_opera_id()
    self.last_opera_id = self.last_opera_id + 1
    return self.last_opera_id
end

function ManageRoleLogic:start()
    ManageRoleLogic.super.start(self)
    self.timer_proxy:firm(Functional.make_closure(ManageRoleLogic.on_frame, self), 1 * 1000, -1)
end

function ManageRoleLogic:stop()
    ManageRoleLogic.super.stop(self)
    self.timer_proxy:release_all()
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

function ManageRoleLogic:launch_role(rpc_rsp, role_id, gate_client_netid, auth_token)
    log_debug("world ManageRoleLogic:launch_role %s %s", role_id, auth_token)
    local role = self.role_id_to_role[role_id]
    if role then
        if Role_State.released == role.state or Role_State.inited == role.state then
            assert(false, string.format("should not reach here %s", role))
            return
        end
        if Role_State.releasing == role.state then
            rpc_rsp:respone(Error.Launch_Role.releasing)
            return
        end
        local old_session = role.session_id

        if Role_State.idle == role.state then
            role.session_id = self:next_session_id()
            role.state = Role_State.using
            role.idle_begin_sec = nil
            rpc_rsp:respone(Error_None, role.game_client.remote_host, role.session_id)
        end
        if Role_State.using == role.state then
            if role.gate_client and role.gate_client.remote_host == rpc_rsp.from_host
                    and role.gate_client_netid and gate_client_netid == role.gate_client_netid then
                rpc_rsp:respone(Error.Launch_Role.repeat_launch)
            else
                if role.gate_client and role.gate_client_netid then
                    role.gate_client:call(nil, GateRpcFn.kick_client, role.gate_client_netid) -- 通知gate踢人
                end
                role.session_id = self:next_session_id()
                rpc_rsp:respone(Error_None, role.game_client.remote_host, role.session_id)
            end
        end
        if Role_State.launch == role.state then
            if role.gate_client and role.gate_client.remote_host == rpc_rsp.from_host
                    and role.gate_client_netid and gate_client_netid == role.gate_client_netid then
                rpc_rsp:respone(Error.Launch_Role.repeat_launch)
            else
                -- 通知上一个client被顶号
                role.cached_launch_rsp:respone(Error.Launch_Role.another_launch)
                role.cached_launch_rsp = rpc_rsp
                role.session_id = self:next_session_id()
                self.service.rpc_mgr:call(
                        Functional.make_closure(self._rpc_rsp_launch_role, self, role.session_id, role_id),
                        service_info.key, GameRpcFn.launch_role, role_id, role.session_id)
            end
        end
        role.gate_client = self.service:create_rpc_client(rpc_rsp.from_host)
        role.gate_client_netid = gate_client_netid
        role.auth_token = auth_token
        self.session_id_to_role[role.session_id] = role
        if old_session and old_session ~= role.session_id then
            self.session_id_to_role[old_session] = nil
        end
    else
        local service_info = self.service.zone_net:rand_service(Service_Const.Game)
        if not service_info then
            rpc_rsp:respone(Error.Launch_Role.no_valid_game_service)
        else
            role = {}
            role.role_id = role_id
            role.auth_token = auth_token
            role.session_id = self:next_session_id()
            role.gate_client = self.service:create_rpc_client(rpc_rsp.from_host)
            role.gate_client_netid = gate_client_netid
            role.game_client = self.service:create_rpc_client(service_info.key)
            role.state = Role_State.inited
            role.cached_launch_rsp = rpc_rsp
            self.role_id_to_role[role.role_id] = role
            self.session_id_to_role[role.session_id] = role
            self.service.rpc_mgr:call(
                    Functional.make_closure(self._rpc_rsp_launch_role, self, role.session_id, role_id),
                    service_info.key, GameRpcFn.launch_role, role_id, role.session_id)
            role.state = Role_State.launch
        end
    end
end

function ManageRoleLogic:_rpc_rsp_launch_role(session_id, role_id, rpc_error_num, launch_error_num)
    local role = self.role_id_to_role[role_id]
    if not role or not role.session_id then
        return -- 可能客户端掉线执行了client_quit,直接返回就好
    end
    if role.session_id ~= session_id then
        role.cached_launch_rsp:respone(Error.Launch_Role.another_launch)
        return -- 应该是被顶号了
    end
    if Role_State.launch ~= role.state then
        log_error("launch role error: role state is not in Role_State.launch, current state is %s", role.state)
        -- todo: 发生了意想不到的错误，让客户端断开连接,让game登出角色，清理role数据
        role.cached_launch_rsp:respone(Error_Unknown)
        if role.gate_client and role.gate_client_netid then
            role.gate_client:call(nil, GateRpcFn.kick_client, role.gate_client_netid) -- 通知gate踢人
        end
        -- todo: 通知game登出角色，
        -- todo: 清理role数据
        self:try_release_role(role_id)
        return
    end

    local fail_action = function(launch_error_num)
        role.cached_launch_rsp:respone(launch_error_num)
        role.cached_launch_rsp = nil
        self.session_id_to_role[role.session_id] = nil
        self.role_id_to_role[role.role_id] = nil
    end

    if Error_None == rpc_error_num and Error_None == launch_error_num then
        role.game_client:call(function(rpc_error_num, launch_error_num)
            if Error_None == rpc_error_num and Error_None == launch_error_num then
                role.state = Role_State.using
                role.cached_launch_rsp:respone(Error_None, role.game_client.remote_host, role.session_id)
                role.cached_launch_rsp = nil
            else
                fail_action(launch_error_num or rpc_error_num)
            end
        end, GameRpcFn.client_change, true, role.gate_client.remote_host, role.gate_client_netid)
    else
        fail_action(launch_error_num or rpc_error_num)
    end
end

function ManageRoleLogic:client_quit(rpc_rsp, session_id)
    rpc_rsp:respone()
    local role = self.session_id_to_role[session_id]
    if role then
        self.session_id_to_role[role.session_id] = nil
        role.session_id = nil
        role.gate_client_netid = nil
        role.gate_client = nil
        local role_state = role.state
        if Role_State.using == role_state then
            role.state = Role_State.idle
            role.idle_begin_sec = logic_sec()
            role.game_client:call(nil, GameRpcFn.client_quit, role.role_id, session_id)
            role.game_client:call(nil, GameRpcFn.client_change, true, nil, nil)
        elseif Role_State.launch == role_state then
            role.game_client:call(nil, GameRpcFn.client_quit, role.role_id, session_id)
            role.game_client:call(nil, GameRpcFn.client_change, true, nil, nil)
        else
            self.role_id_to_role[role.role_id] = nil
            assert(false, string.format("should not reach here %s", role))
        end
    end
    log_debug("ManageRoleLogic:client_quit %s", role)
end

function ManageRoleLogic:on_frame()
    local now_sec = logic_sec()
    local released_roles= {}
    for role_id, role in pairs(self.role_id_to_role) do
        if Role_State.releasing == role.state and self.release_try_times and self.release_begin_sec then
            if self.release_try_times and self.release_try_times > Role_Release_Try_Max_Times or
                Role_Release_Try_Max_Times == self.release_try_times and now_sec >= self.release_begin_sec + Role_Release_Cmd_Expire_Sec then
                table.insert(released_roles, role) -- 如果一直释放role失败，那么强制删掉吧
            end
        end
        if Role_State.idle == role.state and role.idle_begin_sec then
            if now_sec > role.idle_begin_sec + Idle_Role_Hold_Max_Sec  then
                self:try_release_role(role_id)
            end
        end
    end
    for _, role in ipairs(released_roles) do
        role.state = Role_State.released
        if role.session_id then
            self.session_id_to_role[role.session_id] = nil
        end
        self.role_id_to_role[role.role_id] = nil
    end
end

function ManageRoleLogic:try_release_role(role_id)
    log_debug("ManageRoleLogic:try_release_role")
    local role = self.role_id_to_role[role_id]
    if not role then
        return
    end
    role.state = Role_State.releasing
    role.release_try_times = role.release_try_times or 0
    role.release_try_times = role.release_try_times + 1
    role.release_begin_sec = logic_sec()
    role.release_opera_ids = role.release_opera_ids or {}
    local opera_id = self:next_opera_id()
    role.release_opera_ids[opera_id] = true
    role.game_client:call(Functional.make_closure(ManageRoleLogic._rpc_rsp_try_release_role, self, role.role_id, opera_id),
            GameRpcFn.release_role, role.role_id)
end

function ManageRoleLogic:_rpc_rsp_try_release_role(role_id, opera_id, rpc_error_num, logic_error_num)
    local role = self.role_id_to_role[role_id]
    log_debug("ManageRoleLogic:_rpc_rsp_try_release_role %s %s %s", rpc_error_num, logic_error_num, role)
    if not role.release_opera_ids then
        return
    end
    if not role.release_opera_ids[opera_id] then
        return
    end
    if Role_State.releasing ~= role.state then
        return
    end
    if Error_None ~= rpc_error_num or Error_None ~= logic_error_num then
        self:try_release_role(role_id)
        return
    end
    role.state = Role_State.released
    if role.session_id then
        self.session_id_to_role[role.session_id] = nil
    end
    self.role_id_to_role[role.role_id] = nil
end

function ManageRoleLogic:logout_role(rpc_rsp, session_id, role_id)
    log_debug("ManageRoleLogic:logout_role 1")
    local error_num = Error_None
    repeat
        local role = self.session_id_to_role[session_id]
        if not role then
            break
        end
        if role.role_id ~= role_id then
            error_num = Error.Logout_Role.not_match_role
            break
        end
        self.session_id_to_role[role.session_id] = nil
        role.session_id = nil
        role.gate_client = nil
        role.gate_client_netid = nil
        self:try_release_role(role_id)
    until true
    log_debug("ManageRoleLogic:logout_role 2 %s", error_num)
    rpc_rsp:respone(error_num)
end

function ManageRoleLogic:reconnect_role(rpc_rsp, auth_token, role_id, gate_client_netid)
    log_debug("ManageRoleLogic:reconnect_role 1 auth_token:%s", auth_token)
    local error_num = Error_None
    local session_id = -1
    local game_service_key = ""
    repeat
        local role = self.role_id_to_role[role_id]
        if not role then
            error_num = Error.Reconnect_Game.world_no_role
            break
        end
        log_debug("ManageRoleLogic:reconnect_role 2 role_token:%s", role.auth_token)
        if role.auth_token ~= auth_token then
            error_num = Error.Reconnect_Game.token_not_fit
            break
        end
        if Role_State.idle ~= role.state then
            error_num = Error.Reconnect_Game.world_no_role.role_not_idle
            break
        end
        session_id = self:next_opera_id()
        game_service_key = role.game_client.remote_host
        role.state = Role_State.using
        role.session_id = session_id
        role.idle_begin_sec = nil
        role.gate_client = self.service:create_rpc_client(rpc_rsp.from_host)
        role.gate_client_netid = gate_client_netid
        self.session_id_to_role[role.session_id] = role
    until true
    log_debug("ManageRoleLogic:reconnect_role error_num:%s", error_num)
    rpc_rsp:respone(error_num, game_service_key, session_id)
end
