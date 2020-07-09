
---@class RoleStateMgr:LogicEntity
RoleStateMgr = RoleStateMgr or class("RoleStateMgr", LogicEntity)

function RoleStateMgr:_on_init()
    RoleStateMgr.super._on_init(self)
    ---@type CreateRoleServiceMgr
    self.server = self.server
    self._online_world_shadow = self.server.online_world_shadow

    ---@type table<number, WorldRoleState>
    self._role_id_to_role_state = {}

    ---@type table<number, WorldRoleState>
    self._session_id_to_role_state = {}

    self.next_session_id = gen_uuid -- 因为迁移需要，所以不能用自增id了
end

function RoleStateMgr:_on_start()
    RoleStateMgr.super._on_start(self)

    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.world.method.launch_role, Functional.make_closure(self._handle_remote_call_launch_role, self))
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.world.method.logout_role, Functional.make_closure(self._handle_remote_logout_role, self))
end

function RoleStateMgr:_on_stop()
    RoleStateMgr.super._on_stop(self)
end

function RoleStateMgr:_on_release()
    RoleStateMgr.super._on_release(self)
end

function RoleStateMgr:_on_update()
    -- log_print("RoleStateMgr:_on_update")
end

---@param rpc_rsp RpcRsp
function RoleStateMgr:_handle_remote_call_launch_role(rpc_rsp, gate_netid, auth_sn, user_id, role_id)
    log_print("RoleStateMgr:_handle_remote_call_launch_role", netid, auth_sn, user_id, role_id)

    local role_state = self._role_id_to_role_state[role_id]
    if not role_state then
        local game_server_key = self.server.peer_net:random_server_key(Server_Role.Game)
        if not game_server_key then
            rpc_rsp:respone(Error.Launch_Role.no_avaliable_gam)
            return
        end
        role_state = WorldRoleState:new(self, rpc_rsp.from_host, gate_netid, auth_sn, user_id, role_id, self:next_session_id())
        role_state.game_server_key = game_server_key
        self._role_id_to_role_state[role_state.role_id] = role_state
        self._session_id_to_role_state[role_state.session_id] = role_state
        self.cached_rpc_rsp = rpc_rsp
        self._rpc_svc_proxy:call(Functional.make_closure(self._rpc_rsp_launch_role, self, role_id, role_state.session_id),
                role_state.game_server_key, Rpc.game.method.launch_role, role_id, role_state.session_id)
        role_state.state = World_Role_State.launch
    else
        if World_Role_State.released == role_state.state or World_Role_State.inited == role_state.state then
            rpc_rsp:respone(Error_Unknown)
            return
        end
        if World_Role_State.releasing == role_state.state then
            rpc_rsp:report_error(Error.launch_role.releasing)
            return
        end
        local old_session_id = role_state.session_id

        -- 如果正在被使用，那么就顶号
        if World_Role_State.using == role_state then
            if role_state.gate_server_key == rpc_rsp.from_host and role_state.gate_netid == gate_netid then
                rpc_rsp:respone(Error.launch_role.repeat_launch)
            else
                if role_state.gate_server_key and role_state.gate_netid then
                    self._rpc_svc_proxy:call(nil, role_state.gate_server_key, Rpc.gate.method.kick_client, role_state.gate_netid)
                    role_state.gate_server_key = nil
                    role_state.gate_netid = nil
                end
                role_state.session_id = self:next_session_id()
                rpc_rsp:respone(Error_None, role_state.game_server_key, role_state.session_id)
                self._rpc_svc_proxy:call(nil, Rpc.world.method.change_gate_client, role_state.role_id, false, rpc_rsp.from_host, gate_netid)
            end
        end

        -- 如果正在launch过程中，用新的launch过程挤掉上一个launch过程。这么做相对简单
        if World_Role_State.launch == role_state.state then
            if role_state.gate_server_key == rpc_rsp.from_host and role_state.gate_netid == gate_netid then
                rpc_rsp:respone(Error.launch_role.repeat_launch)
            else
                role_state.cached_rpc_rsp:respone(Error.launch_role.another_launch)
                role_state.cached_rpc_rsp = rpc_rsp
                role_state.session_id = self:next_session_id()
                self._rpc_svc_proxy:call(Functional.make_closure(self._rpc_rsp_launch_role, self, role_id, role_state.session_id),
                    role_state.game_server_key, Rpc.game.method.launch_role, role_id, role_state.session_id)
            end
        end

        -- 如果是闲置状态，直接接上就好了
        if World_Role_State.idle == role_state.state then
            role_state.session_id = self:next_session_id()
            role_state.state = World_Role_State.using
            role_state.idle_begin_sec = nil
            rpc_rsp:respone(Error_None, role_state.game_server_key, role_state.session_id)
            self._rpc_svc_proxy:call(nil, Rpc.world.method.change_gate_client, role_state.role_id, false, rpc_rsp.from_host, gate_netid)
        end

        -- 最后维护好gate_server_key、gate_netid、auth_sn和self._session_id_to_role_state数据正确
        role_state.gate_server_key = rpc_rsp.from_host
        role_state.gate_netid = gate_netid
        role_state.auth_sn = auth_sn
        self._session_id_to_role_state[role_state.session_id] = role_state
        if old_session_id ~= role_state.session_id then
            self._session_id_to_role_state[old_session_id] = nil
        end
    end
end

function RoleStateMgr:_rpc_rsp_launch_role(role_id, session_id, rpc_error_num, error_num)
    local picked_error = pick_error_num(rpc_error_num, error_num)
    local role_state = self._role_id_to_role_state[role_id]
    if not role_state then
        return
    end
    if not role_state.session_id then
        -- role_state没有被占用，若launch成功了直接释放role比较简单；若launch失败了，销毁数据
        if Error_None == picked_error then
            self:try_release_role()
        else
            self.session_id_to_role[role.session_id] = nil
            self.role_id_to_role[role.role_id] = nil
        end
        return
    end
    if role_state.session_id ~= session_id then
        -- session_id 应该是被顶号了
        return
    end

    if World_Role_State.launch ~= role_state.state then
        -- todo: 发生了意想不到的错误，让客户端断开连接,让game清理role数据
        role_state.cached_rpc_rsp:respone(Error_Unknown)
        if role_state.gate_server_key and role_state.gate_netid then
            self._rpc_svc_proxy:call(nil, role_state.gate_server_key, Rpc.gate.method.kick_client, role_state.gate_netid)
        end
        if Error_None == picked_error then
            self:try_release_role()
        else
            self.session_id_to_role[role.session_id] = nil
            self.role_id_to_role[role.role_id] = nil
        end
        return
    end

    if Error_None ~= picked_error then
        role_state.cached_rpc_rsp:respone(picked_error)
        role_state.cached_rpc_rsp = nil
        self.session_id_to_role[role.session_id] = nil
        self.role_id_to_role[role.role_id] = nil
    else
        self._rpc_svc_proxy:call(
                Functional.make_closure(self._rpc_rsp_bind_game_role_to_gate_client_after_launch, self, role_id, session_id),
                role_state.game_server_key, Rpc.game.method.change_gate_client,
                role_state.role_id, false, role_state.gate_server_key, role_state.gate_netid)
    end
end

function RoleStateMgr:_rpc_rsp_bind_game_role_to_gate_client_after_launch(role_id, session_id, rpc_error_num, error_num)
    local picked_error = pick_error_num(rpc_error_num, error_num)
    local role_state = self._role_id_to_role_state[role_id]
    if not role_state then
        return
    end
    if not role_state.session_id then
        -- role_state没有被占用,，此时launch已经成功了，那么执行try_release_role比较简单
        self:try_release_role()
        return
    end
    if role_state.session_id ~= session_id then
        -- session_id 应该是被顶号了
        return
    end

    if World_Role_State.launch ~= role_state.state then
        -- todo: 发生了意想不到的错误，让客户端断开连接,让game清理role数据
        role_state.cached_rpc_rsp:respone(Error_Unknown)
        if role_state.gate_server_key and role_state.gate_netid then
            self._rpc_svc_proxy:call(nil, role_state.gate_server_key, Rpc.gate.method.kick_client, role_state.gate_netid)
        end
        self:try_release_role()
        return
    end

    if Error_None == picked_error then
        role.state = Role_State.using
        role.cached_launch_rsp:respone(Error_None, role_state.gate_server_key, role_state.session_id)
        role.cached_launch_rsp = nil
    else
        self:try_release_role(role_state.role_id)
    end
end

function RoleStateMgr:try_release_role(role_id)
    log_debug("RoleMgr:try_release_role")
    local role_state = self._role_id_to_role_state[role_id]
    if not role_state then
        return
    end
    role_state.state = Role_State.releasing
    role_state.release_try_times = role_state.release_try_times or 0
    role_state.release_try_times = role_state.release_try_times + 1
    role_state.release_begin_sec = logic_sec()
    role_state.release_opera_ids = role_state.release_opera_ids or {}
    local opera_id = self:next_opera_id()
    role_state.release_opera_ids[opera_id] = true
    self._rpc_svc_proxy:call(
            Functional.make_closure(RoleMgr._rpc_rsp_try_release_role, self, role_state.role_id, opera_id),
            Role_State.gate_server_key, Rpc.game.method.release_role, role.role_id)
end

function RoleStateMgr:_rpc_rsp_try_release_role(role_id, opera_id, rpc_error_num)
    local role_state = self._role_id_to_role_state[role_id]
    log_debug("RoleMgr:_rpc_rsp_try_release_role %s %s", role_id, rpc_error_num, error_num)
    if not role_state or not role_state.release_opera_ids or not role_state.release_opera_ids[opera_id] then
        return
    end
    if World_Role_State.releasing ~= role_state.state then
        return
    end
    if Error_None ~= rpc_error_num then
        self:try_release_role(role_id)
        return
    end

    role_state.state = Role_State.released
    self._role_id_to_role_state[role_state.role_id] = nil
    if role_state.session_id then
        self.session_id_to_role[role_state.session_id] = nil
    end
end

---@param rpc_rsp RpcRsp
function RoleStateMgr:_handle_remote_logout_role(rpc_rsp, user_id, role_id)
    rpc_rsp:respone(Error_None)
end
