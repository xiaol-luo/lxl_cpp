
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
    self._gate_session_to_role_state = {}

    self.next_session_id = make_sequence(0)
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
function RoleStateMgr:_handle_remote_call_launch_role(rpc_rsp, netid, auth_sn, user_id, role_id)
    log_print("RoleStateMgr:_handle_remote_call_launch_role", netid, auth_sn, user_id, role_id)

    local role_state = self._role_id_to_role_state[role_id]
    if not role_state then
        local game_server_key = self.server.peer_net:random_server_key(Server_Role.Game)
        if not game_server_key then
            rpc_rsp:respone(Error.Launch_Role.no_avaliable_gam)
            return
        end
        role_state = WorldRoleState:new(self, rpc_rsp.from_host, netid, auth_sn, user_id, role_id, self:next_session_id())
        role_state.game_server_key = game_server_key
        self._role_id_to_role_state[role_state.role_id] = role_state
        self._gate_session_to_role_state[role_state.session_id] = role_state
        self.cached_rpc_rsp = rpc_rsp
        self._rpc_svc_proxy:call(Functional.make_closure(self._rpc_rsp_launch_role, self, role_id, role_state.session_id),
                role_state.game_server_key, Rpc.game.method.launch_role, role_id, role_state.session_id)
    end
    rpc_rsp:respone(Error_None)
end

function RoleStateMgr:_rpc_rsp_launch_role(role_id, session_id, rpc_error_num, launch_error_num)
    local role_state = self._role_id_to_role_state[role_id]
    if not role_state or not role_state.session_id then
        return -- 可能客户端掉线执行了client_quit,直接返回就好
    end
    if role_state.session_id ~= session_id then
        role_state.cached_launch_rsp:respone(Error.Launch_Role.another_launch)
        return -- 应该是被顶号了
    end
end

---@param rpc_rsp RpcRsp
function RoleStateMgr:_handle_remote_logout_role(rpc_rsp, user_id, role_id)
    rpc_rsp:respone(Error_None)
end

