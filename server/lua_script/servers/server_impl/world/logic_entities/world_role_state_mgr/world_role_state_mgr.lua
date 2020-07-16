
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

    -- self._next_session_id = gen_uuid -- 因为迁移需要，所以不能用自增id了
    self._next_session_id = make_sequence(0) -- 因为迁移需要，所以不能用自增id了

    self._next_opera_id = make_sequence(0)
end

function RoleStateMgr:_on_start()
    RoleStateMgr.super._on_start(self)

    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.world.method.launch_role, Functional.make_closure(self._handle_remote_call_launch_role, self))
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.world.method.logout_role, Functional.make_closure(self._handle_remote_call_logout_role, self))
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.world.method.reconnect_role, Functional.make_closure(self._handle_remote_call_reconnect_role, self))
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.world.method.gate_client_quit, Functional.make_closure(self._handle_remote_call_gate_client_quit, self))
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
    local old_session_id = nil
    local role_state = self._role_id_to_role_state[role_id]
    if not role_state then
        local game_server_key = self.server.peer_net:random_server_key(Server_Role.Game)
        if not game_server_key then
            rpc_rsp:response(Error_Not_Available_Server)
            return
        end
        role_state = WorldRoleState:new(self, rpc_rsp.from_host, gate_netid, auth_sn, user_id, role_id, self:_next_session_id())
        role_state.game_server_key = game_server_key
        role_state.cached_rpc_rsp = rpc_rsp
        self._role_id_to_role_state[role_state.role_id] = role_state
        self._session_id_to_role_state[role_state.session_id] = role_state
        self._rpc_svc_proxy:call(Functional.make_closure(self._rpc_rsp_launch_role, self, role_id, role_state.session_id),
                role_state.game_server_key, Rpc.game.method.launch_role, user_id, role_id)
        role_state.state = World_Role_State.launch
        old_session_id = role_state.session_id
    else
        if World_Role_State.released == role_state.state or World_Role_State.inited == role_state.state then
            rpc_rsp:response(Error_Unknown)
            return
        end
        if World_Role_State.releasing == role_state.state then
            rpc_rsp:report_error(Error.launch_role.releasing)
            return
        end
        old_session_id = role_state.session_id

        -- 如果正在被使用，那么就顶号
        if World_Role_State.using == role_state.state then
            if role_state.gate_server_key == rpc_rsp.from_host and role_state.gate_netid == gate_netid then
                rpc_rsp:response(Error.launch_role.repeat_launch, role_state.game_server_key, role_state.session_id)
            else
                if role_state.gate_server_key and role_state.gate_netid then
                    self._rpc_svc_proxy:call(nil, role_state.gate_server_key, Rpc.gate.method.kick_client, role_state.gate_netid)
                    role_state.gate_server_key = nil
                    role_state.gate_netid = nil
                end
                role_state.session_id = self:_next_session_id()
                rpc_rsp:response(Error_None, role_state.game_server_key, role_state.session_id)
                -- todo: 这里很可能game暂时和world断开连接，得想个修复策略，gate信息不一致，那么就向world请求下gate信息
                self._rpc_svc_proxy:call(nil, role_state.game_server_key, Rpc.game.method.change_gate_client, role_state.role_id, false, rpc_rsp.from_host, gate_netid)
            end
        end

        -- 如果正在launch过程中，用新的launch过程挤掉上一个launch过程。这么做相对简单
        if World_Role_State.launch == role_state.state then
            if role_state.gate_server_key == rpc_rsp.from_host and role_state.gate_netid == gate_netid then
                rpc_rsp:response(Error.launch_role.repeat_launch, role_state.game_server_key, role_state.session_id)
            else
                if role_state.cached_rpc_rsp then
                    role_state.cached_rpc_rsp:response(Error.launch_role.another_launch)
                end
                role_state.cached_rpc_rsp = rpc_rsp
                role_state.session_id = self:_next_session_id()
                self._rpc_svc_proxy:call(Functional.make_closure(self._rpc_rsp_launch_role, self, role_id, role_state.session_id),
                    role_state.game_server_key, Rpc.game.method.launch_role, user_id, role_id)
            end
        end

        -- 如果是闲置状态，直接接上就好了
        if World_Role_State.idle == role_state.state then
            role_state.session_id = self:_next_session_id()
            role_state.state = World_Role_State.using
            role_state.idle_begin_sec = nil
            rpc_rsp:response(Error_None, role_state.game_server_key, role_state.session_id)
            -- todo: 这里很可能game暂时和world断开连接，得想个修复策略，gate信息不一致，那么就向world请求下gate信息
            self._rpc_svc_proxy:call(nil, role_state.game_server_key, Rpc.game.method.change_gate_client, role_state.role_id, false, rpc_rsp.from_host, gate_netid)
        end

        -- 最后维护好gate_server_key、gate_netid、auth_sn和self._session_id_to_role_state数据正确
        role_state.gate_server_key = rpc_rsp.from_host
        role_state.gate_netid = gate_netid
        role_state.auth_sn = auth_sn
        self._session_id_to_role_state[role_state.session_id] = role_state
        if old_session_id and old_session_id ~= role_state.session_id then
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
            self._session_id_to_role_state[role_state.session_id] = nil
            self._role_id_to_role_state[role_state.role_id] = nil
        end
        return
    end
    if role_state.session_id ~= session_id then
        -- session_id 应该是被顶号了
        return
    end

    if World_Role_State.launch ~= role_state.state then
        -- todo: 发生了意想不到的错误，让客户端断开连接,让game清理role数据
        if role_state.cached_rpc_rsp then
            role_state.cached_rpc_rsp:response(Error_Unknown)
        end
        role_state.cached_rpc_rsp = nil

        if role_state.gate_server_key and role_state.gate_netid then
            self._rpc_svc_proxy:call(nil, role_state.gate_server_key, Rpc.gate.method.kick_client, role_state.gate_netid)
        end
        if Error_None == picked_error then
            self:try_release_role()
        else
            self._session_id_to_role_state[role_state.session_id] = nil
            self._role_id_to_role_state[role_state.role_id] = nil
        end
        return
    end

    if Error_None ~= picked_error then
        if role_state.cached_rpc_rsp then
            role_state.cached_rpc_rsp:response(picked_error)
        end
        role_state.cached_rpc_rsp = nil

        self._session_id_to_role_state[role_state.session_id] = nil
        self._role_id_to_role_state[role_state.role_id] = nil
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
        if role_state.cached_rpc_rsp then
            role_state.cached_rpc_rsp:response(Error_Unknown)
        end
        role_state.cached_rpc_rsp = nil

        if role_state.gate_server_key and role_state.gate_netid then
            self._rpc_svc_proxy:call(nil, role_state.gate_server_key, Rpc.gate.method.kick_client, role_state.gate_netid)
        end
        self:try_release_role()
        return
    end

    if Error_None == picked_error then
        role_state.state = World_Role_State.using
        if role_state.cached_rpc_rsp then
            role_state.cached_rpc_rsp:response(Error_None, role_state.gate_server_key, role_state.session_id)
        end
        role_state.cached_rpc_rsp = nil
    else
        self:try_release_role(role_state.role_id)
    end
end

function RoleStateMgr:try_release_role(role_id)
    local role_state = self._role_id_to_role_state[role_id]
    if not role_state then
        return
    end
    role_state.state = World_Role_State.releasing
    role_state.release_try_times = role_state.release_try_times or 0
    role_state.release_try_times = role_state.release_try_times + 1
    role_state.release_begin_sec = logic_sec()
    role_state.release_opera_ids = role_state.release_opera_ids or {}
    local opera_id = self:_next_opera_id()
    role_state.release_opera_ids[opera_id] = true
    if role_state.gate_server_key and role_state.gate_netid then
        self._rpc_svc_proxy:call(nil, role_state.gate_server_key, Rpc.gate.method.kick_client, role_state.gate_netid)
    end
    self._rpc_svc_proxy:call(
            Functional.make_closure(self._rpc_rsp_try_release_role, self, role_state.role_id, opera_id),
            role_state.game_server_key, Rpc.game.method.release_role, role_state.role_id)
end

function RoleStateMgr:_rpc_rsp_try_release_role(role_id, opera_id, rpc_error_num, error_num)
    local role_state = self._role_id_to_role_state[role_id]
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

    role_state.state = World_Role_State.released
    self._role_id_to_role_state[role_state.role_id] = nil
    if role_state.session_id then
        self._session_id_to_role_state[role_state.session_id] = nil
    end
end

function RoleStateMgr:_handle_remote_call_reconnect_role(rpc_rsp, gate_netid, role_id, auth_sn)
    local error_num = Error_None

    repeat
        local role_state = self._role_id_to_role_state[role_id]
        if not role_state then
            error_num = Error.reconnect_role.not_find_role
            break
        end
        if role_state.auth_sn ~= auth_sn then
            error_num = Error.reconnect_role.auth_sn_mismatch
            break
        end
        if World_Role_State.idle ~= role_state.state then
            error_num = Error.reconnect_role.role_not_idle
            break
        end
        if not role_state.game_server_key then
            error_num = Error_Unknown
            break
        end
        role_state.state = World_Role_State.using
        role_state.idle_begin_sec = nil
        role_state.session_id = self:_next_session_id()
        role_state.gate_server_key = rpc_rsp.from_host
        role_state.gate_netid = gate_netid
        self._session_id_to_role_state[role_state.session_id] = role_state
        self._rpc_svc_proxy:call(
                Functional.make_closure(self._rpc_rsp_bind_game_role_to_gate_client_for_reconnect_role, self, rpc_rsp, role_state.session_id, role_id),
                role_state.game_server_key, Rpc.game.method.change_gate_client, role_state.role_id, false, role_state.gate_server_key, role_state.gate_netid)
    until true

    if Error_None ~= error_num then
        rpc_rsp:response(error_num)
    end
end

function RoleStateMgr:_rpc_rsp_bind_game_role_to_gate_client_for_reconnect_role(rpc_rsp, session_id, role_id, rpc_error_num, error_num)
    local role_state = self._role_id_to_role_state[role_id]
    if not role_state or not role_state.session_id or session_id ~= role_state.session_id then
        rpc_rsp:response(Error_Unknown)
        return
    end
    local picked_error = pick_error_num(rpc_error_num, error_num)
    if Error_None ~= picked_error or World_Role_State.using ~= role_state.state then
        rpc_rsp:response(picked_error)
        -- 执行try_release_role比较简单
        self:try_release_role(role_state.role_id)
    else
        rpc_rsp:response(Error_None, role_state.game_server_key, role_state.session_id)
    end
end

---@param rpc_rsp RpcRsp
function RoleStateMgr:_handle_remote_call_logout_role(rpc_rsp, session_id)
    local error_num = Error_None
    repeat
        local role_state = self._session_id_to_role_state[session_id]
        if not role_state then
            error_num = Error.logout_role.not_find_world_role
            break
        end
        self._session_id_to_role_state[session_id] = nil
        role_state.session_id = nil
        role_state.gate_server_key = nil
        role_state.gate_netid = nil
        self:try_release_role(role_state.role_id)
    until true
    rpc_rsp:response(error_num)
end

function RoleStateMgr:_handle_remote_call_gate_client_quit(rpc_rsp, session_id)
    rpc_rsp:response()
    local role_state = self._session_id_to_role_state[session_id]
    if role_state then
        self._session_id_to_role_state[session_id] = nil
        role_state.session_id = nil
        role_state.gate_server_key = nil
        local old_role_state = role_state.state
        if World_Role_State.using == old_role_state then
            role_state.state = World_Role_State.idle
            role_state.idle_begin_sec = logic_sec()
            self._rpc_svc_proxy:call(nil, role_state.game_server_key, Rpc.game.method.change_gate_client, true, nil, nil)
        elseif World_Role_State.launch == role_state then
            self:try_release_role(role_state.role_id)
        else
            self:try_release_role(role_state.role_id)
            log_error("RoleStateMgr:_handle_remote_call_gate_client_quit error: role_id %s role_state %", role_state.role_id, role_state.state)
        end
    end
end
