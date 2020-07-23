
---@class RoleStateMgr:LogicEntity
RoleStateMgr = RoleStateMgr or class("RoleStateMgr", LogicEntity)

function RoleStateMgr:_on_init()
    RoleStateMgr.super._on_init(self)
    ---@type CreateRoleServiceMgr
    self.server = self.server
    ---@type OnlineWorldShadow
    self._online_world_shadow = self.server.online_world_shadow

    ---@type table<number, WorldRoleState>
    self._role_id_to_role_state = {}

    ---@type table<number, WorldRoleState>
    self._session_id_to_role_state = {}

    -- self._next_session_id = gen_uuid -- 因为迁移需要，所以不能用自增id了
    self._next_session_id = make_sequence(0) -- 因为迁移需要，所以不能用自增id了

    self._next_opera_id = make_sequence(0)

    self._online_world_shadow_aprted_release_all_roles_tid = nil

    self._check_idle_roles_last_sec = 0
    self._check_match_game_roles_last_sec = 0
end

function RoleStateMgr:_on_start()
    RoleStateMgr.super._on_start(self)

    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.world.method.launch_role, Functional.make_closure(self._handle_remote_call_launch_role, self))
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.world.method.logout_role, Functional.make_closure(self._handle_remote_call_logout_role, self))
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.world.method.reconnect_role, Functional.make_closure(self._handle_remote_call_reconnect_role, self))
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.world.method.gate_client_quit, Functional.make_closure(self._handle_remote_call_gate_client_quit, self))
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.world.method.notify_release_game_roles, Functional.make_closure(self._handle_remote_call_notify_release_game_roles, self))
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.world.method.transfer_world_role, Functional.make_closure(self._handle_remote_call_transfer_world_role, self))
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.world.method.check_match_world_roles, Functional.make_closure(self._handle_remote_call_check_match_world_roles, self))
    self._event_binder:bind(self._online_world_shadow, Online_World_Event.adjusting_version_state_change,
            Functional.make_closure(self._on_event_adjusting_version_state_change, self))
    self._event_binder:bind(self._online_world_shadow, Online_World_Event.shadow_parted_state_change,
            Functional.make_closure(self._on_event_shadow_parted_state_change, self))
end

function RoleStateMgr:_on_stop()
    RoleStateMgr.super._on_stop(self)
end

function RoleStateMgr:_on_release()
    RoleStateMgr.super._on_release(self)
end

function RoleStateMgr:_on_update()
    -- log_print("RoleStateMgr:_on_update")
    local now_sec = logic_sec()
    self:_check_and_release_idle_roles(now_sec)
    self:_check_match_game_roles(now_sec)
end

function RoleStateMgr:_check_and_release_idle_roles(now_sec)
    if now_sec - self._check_idle_roles_last_sec < World_Role_State_Const.check_idle_role_span_sec then
        return
    end
    self._check_idle_roles_last_sec = now_sec

    for role_id, role_state in pairs(self._role_id_to_role_state) do
        if World_Role_State.idle == role_state.state then
            if nil == role_state.idle_begin_sec
                    or now_sec - role_state.idle_begin_sec >= World_Role_State_Const.release_idle_role_after_span_sec then
                self:try_release_role(role_id)
            end
        end
    end
end

---@param rpc_rsp RpcRsp
function RoleStateMgr:_handle_remote_call_launch_role(rpc_rsp, gate_netid, auth_sn, user_id, role_id)
    if self._online_world_shadow:is_parted() then
        rpc_rsp:response(Error_Server_Online_Shadow_Parted)
        return
    end
    if self._online_world_shadow:is_adjusting_version() then
        rpc_rsp:response(Error_Consistent_Hash_Adjusting)
        return
    end

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
        -- todo: 增加尝试次数
        -- self:try_release_role(role_id)
        -- return
    end

    role_state.state = World_Role_State.released
    self._role_id_to_role_state[role_state.role_id] = nil
    if role_state.session_id then
        self._session_id_to_role_state[role_state.session_id] = nil
    end
end

function RoleStateMgr:_handle_remote_call_reconnect_role(rpc_rsp, gate_netid, role_id, auth_sn)
    if self._online_world_shadow:is_parted() then
        rpc_rsp:response(Error_Server_Online_Shadow_Parted)
        return
    end
    if self._online_world_shadow:is_adjusting_version() then
        rpc_rsp:response(Error_Consistent_Hash_Adjusting)
        return
    end

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
            log_warn("RoleStateMgr:_handle_remote_call_gate_client_quit error: role_id %s role_state %s", role_state.role_id, role_state.state)
            self:try_release_role(role_state.role_id)
        end
    end
end

function RoleStateMgr:_handle_remote_call_notify_release_game_roles(rpc_rsp, role_ids)
    rpc_rsp:response()
    for _, role_id in pairs(role_ids or {}) do
        self:try_release_role(role_id)
    end
end

function RoleStateMgr:_handle_remote_call_transfer_world_role(rpc_rsp, role_state_data)
    log_print("RoleStateMgr:_handle_remote_call_transfer_world_role ", role_state_data.role_id, self.server:get_cluster_server_key())
    if self._online_world_shadow:is_parted() then
        rpc_rsp:response(Error_Server_Online_Shadow_Parted)
        return
    end
    local role_id = role_state_data.role_id
    local self_server_key = self.server:get_cluster_server_key()
    local want_world_server_key = self._online_world_shadow:cal_server_address(role_id)
    if want_world_server_key ~= self_server_key then
        rpc_rsp:response(Error_Consistent_Hash_Mismatch)
        return
    end
    if self._role_id_to_role_state[role_id] then
        rpc_rsp:response(Error.transfer_world_role.role_id_already_exist)
        return
    end
    local session_id = role_state_data.session_id
    if self._session_id_to_role_state[session_id] then
        rpc_rsp:response(Error.transfer_world_role.session_id_already_exist)
        return
    end

    -- mgr, gate_server_key, gate_netid, auth_sn, user_id, role_id, session_id
    local role_state = WorldRoleState:new(self, role_state_data.gate_server_key, role_state_data.gate_netid,
        role_state_data.auth_sn, role_state_data.user_id, role_id, session_id)
    role_state.game_server_key = role_state_data.game_server_key
    role_state.state = role_state_data.state
    role_state.idle_begin_sec = role_state_data.idle_begin_sec
    self._role_id_to_role_state[role_id] = role_state
    self._session_id_to_role_state[session_id] = role_state
    rpc_rsp:response(Error_None)
    self._rpc_svc_proxy(Functional.make_closure(self._rpc_rsp_bind_world, self, session_id),
        role_state.game_server_key, Rpc.game.method.bind_world, role_id)
end

function RoleStateMgr:_handle_remote_call_check_match_world_roles(rpc_rsp, role_ids)
    local mismatch_role_ids = {}
    for _, role_id in pairs(role_ids) do
        local role_state = self._role_id_to_role_state[role_id]
        if not role_state or role_state.game_server_key ~= rpc_rsp.from_host then
            table.insert(mismatch_role_ids, role_id)
        end
    end
    rpc_rsp:response(Error_None, mismatch_role_ids)
end

function RoleStateMgr:_rpc_rsp_bind_world(session_id, rpc_error_num, logic_error_num)
    local role_state = self._session_id_to_role_state[session_id]
    if not role_state then
        return
    end
    if Error_None ~= pick_error_num(rpc_error_num, logic_error_num) then
        self:try_release_role(role_state.role_id)
        return
    end
end

function RoleStateMgr:try_transfer_world_role(role_id, try_times)
    local self_server_key = self.server:get_cluster_server_key()
    local target_server_key = self._online_world_shadow:cal_server_address(role_id)
    if target_server_key or target_server_key == self_server_key then
        return
    end
    local role_state = self._role_id_to_role_state[role_id]
    if nil == role_state then
        return
    end

    local role_state_data = {}
    role_state_data.state = role_state.state
    role_state_data.role_id = role_state.role_id
    role_state_data.user_id = role_state.user_id
    role_state_data.session_id = role_state.session_id
    role_state_data.gate_server_key = role_state.gate_server_key
    role_state_data.gate_netid = role_state.gate_netid
    role_state_data.auth_sn = role_state.auth_sn
    role_state_data.idle_begin_sec = role_state.idle_begin_sec
    self._rpc_svc_proxy:call(Functional.make_closure(self.rpc_rsp_transfer_world_role, self, role_state.session_id, try_times),
            target_server_key, Rpc.game.method.transfer_world_role, role_state_data)

end

function RoleStateMgr:rpc_rsp_transfer_world_role(session_id, try_times, rpc_error_num, logic_error_num)
    log_print("RoleStateMgr:rpc_rsp_transfer_world_role ", self.server:get_cluster_server_key(), session_id, try_times, rpc_error_num, logic_error_num)

    local role_state = self._session_id_to_role_state[session_id]
    if not role_state then
        return
    end

    local picked_error_num = pick_error_num(rpc_error_num, logic_error_num)
    if Error_None == picked_error_num then
        if self._online_world_shadow:is_adjusting_version() and try_times < World_Role_State_Const.transfer_role_try_max_times then
            self._timer_proxy:delay(Functional.make_closure(self.try_release_role, self, role_state.role_id, try_times + 1),
                    World_Role_State_Const.transfer_role_try_span_ms)
        else
            self:try_release_role(role_state.role_id)
        end
        return
    end
    self._session_id_to_role_state[session_id] = nil
    self._role_id_to_role_state[role_state.role_id] = nil
end

function RoleStateMgr:_on_event_adjusting_version_state_change(is_adjusting)
    if is_adjusting then
        for role_id, role_state in pairs(self._role_id_to_role_state) do
            if World_Role_State.using ~= role_state.state
                    and World_Role_State.idle ~= role_state.state
            then
                self:try_release_role(role_state.role_id)
            else
                self:try_transfer_world_role(role_id, 1)
            end
        end
    else
        local self_server_key = self.server:get_cluster_server_key()
        for role_id, _ in pairs(self._role_id_to_role_state) do
            local want_world_server_key = self._online_world_shadow:cal_server_address(role_id)
            if want_world_server_key ~= self_server_key then
                self:try_release_role(role_id)
            end
        end
    end
end

function RoleStateMgr:_on_event_shadow_parted_state_change(is_parted)
    self:_try_release_all_roles_for_online_world_shadow_parted(is_parted)
end

function RoleStateMgr:_try_release_all_roles_for_online_world_shadow_parted(need_release)
    if self._online_world_shadow_aprted_release_all_roles_tid then
        self._timer_proxy:remove(self._online_world_shadow_aprted_release_all_roles_tid)
        self._online_world_shadow_aprted_release_all_roles_tid = nil
    end
    if need_release then
        self._online_world_shadow_aprted_release_all_roles_tid = self._timer_proxy:delay(function ()
            self._online_world_shadow_aprted_release_all_roles_tid = nil
            for _, role_state in pairs(self._role_id_to_role_state) do
                if World_Role_State.using == role_state.state
                        or World_Role_State.idle == role_state.state
                        or World_Role_State.launch == role_state.state then
                    self:try_release_role(role_state.role_id)
                end
            end
        end, World_Role_State_Const.after_n_secondes_release_all_role * MICRO_SEC_PER_SEC)
    end
end

function RoleStateMgr:_check_match_game_roles(now_sec)
    if now_sec - self._check_match_game_roles_last_sec < World_Role_State_Const.check_match_game_role_span_sec then
        return
    end
    self._check_match_game_roles_last_sec = now_sec

    log_print("RoleStateMgr:_check_match_game_roles ", table.size(self._role_id_to_role_state))

    local game_to_role_ids = {}
    for role_id, role_state in pairs(self._role_id_to_role_state) do
        if World_Role_State.idle == role_state.state or World_Role_State.using == role_state.state then
            local game_server_key = role_state.game_server_key
            local role_ids = game_to_role_ids[game_server_key]
            if not role_ids then
                role_ids = {}
                game_to_role_ids[game_server_key] = role_ids
            end
            table.insert(role_ids, role_id)
            if #role_ids >= World_Role_State_Const.check_match_game_role_count_per_rpc_query then
                self:_do_check_match_game_roles(1, game_server_key, role_ids)
                game_to_role_ids[game_server_key] = {}
            end
        end
    end
    for game_server_key, role_ids in pairs(game_to_role_ids) do
        if #role_ids > 0 then
            self:_do_check_match_game_roles(1, game_server_key, role_ids)
        end
    end
end

function RoleStateMgr:_do_check_match_game_roles(try_times, game_server_key, role_ids)
    self._rpc_svc_proxy:call(function(rpc_error_num, logic_error_num, mismatch_role_ids)
        log_print("wwwww RoleStateMgr:_do_check_match_game_roles", rpc_error_num, logic_error_num, game_server_key, mismatch_role_ids, role_ids)
        local release_role_ids = mismatch_role_ids
        if Error_None ~= pick_error_num(rpc_error_num, logic_error_num) then
            local Max_Try_Times = 3
            local Delay_Try_Ms = 2000
            if try_times <= Max_Try_Times then
                self._timer_proxy:delay(Functional.make_closure(self._do_check_match_game_roles,
                        self, try_times + 1, game_server_key, role_ids), Delay_Try_Ms)
                return
            else
                release_role_ids = role_ids
            end
            for _, role_id in pairs(release_role_ids) do
                self:try_release_role(role_id)
            end
        end
    end, game_server_key, Rpc.game.method.check_match_game_roles, role_ids)
end