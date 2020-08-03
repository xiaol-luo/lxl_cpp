
---@class GameUser:DataBase
GameUser = GameUser or class("GameUser", DataBase)

function GameUser:ctor(data_mgr)
    log_print("mainrole !!!!!!!!!!!!!!!!!", GameUser, DataBase)
    GameUser.super.ctor(self, data_mgr, "game_user")
    ---@type NetMgr
    self._net_mgr = self._app.net_mgr
    self._user_id = -1
    self._launch_role_id = -1
    self._last_try_launch_role_id = -1
    self._role_digests = {}
    self._is_role_reachable = false
end

function GameUser:_on_init()
    GameUser.super._on_init(self)
    self._event_binder:bind(self._app.net_mgr, Game_Net_Event.game_login_done,
            Functional.make_closure(self._on_event_game_login_done, self))
    self._event_binder:bind(self._app.net_mgr, Game_Net_Event.gate_connect_done,
            Functional.make_closure(self._on_event_gate_connect_done, self))
    self._event_binder:bind(self._app.net_mgr, Game_Net_Event.gate_connect_ready_change,
            Functional.make_closure(self._on_event_gate_connect_ready_change, self))
    self._event_binder:bind(self._app.net_mgr, Login_Pid.rsp_pull_role_digest,
            Functional.make_closure(self._on_msg_rsp_pull_role_digest, self))
    self._event_binder:bind(self._app.net_mgr, Login_Pid.rsp_create_role,
            Functional.make_closure(self._on_msg_rsp_create_role, self))
    self._event_binder:bind(self._app.net_mgr, Login_Pid.rsp_launch_role,
            Functional.make_closure(self._on_msg_rsp_launch_role, self))
    self._event_binder:bind(self._app.net_mgr, Login_Pid.req_logout_role,
            Functional.make_closure(self._on_msg_rsp_logout_role, self))
    self._event_binder:bind(self._app.net_mgr, Login_Pid.req_reconnect_role,
            Functional.make_closure(self._on_msg_rsp_reconnect_role, self))
end

function GameUser:_on_release()
    GameUser.super._on_release(self)
end

function GameUser:get_role_digests()
    return self._role_digests
end

function GameUser:get_user_id()
    return self._user_id
end

function GameUser:get_launch_role_id()
    return self._launch_role_id
end

function GameUser:_on_event_game_login_done(is_ready, error_msg)
    if is_ready then
        local old_user_id = self._user_id
        self._user_id = self._net_mgr.game_login_net:get_user_id()
        if old_user_id ~= self._user_id then
            self._role_digests = {}
        end
        self._launch_role_id = nil
    end
end

function GameUser:_on_event_gate_connect_done(is_ready, error_msg)
    log_print("GameUser:_on_event_gate_connect_done", is_ready, error_msg)
    if is_ready then
        self:pull_role_digest(nil)
    end
end

function GameUser:_on_event_gate_connect_ready_change(is_ready)
    if not is_ready then
        self:_set_role_reachable(false)
    end
end

function GameUser:pull_role_digest(role_id)
    return self._app.net_mgr.game_gate_net:send_msg_to_gate(Login_Pid.req_pull_role_digest, {role_id = role_id })
end

function GameUser:_on_msg_rsp_pull_role_digest(pto_id, msg)
    log_print("GameUser:on_msg_rsp_pull_role_digest 11111 xxx ", pto_id, "zzz", msg)
    if Error_None ==  msg.error_num then
        if 0 == msg.role_id then
            self.role_digests = {}
        else
            self.role_digests[msg.role_id] = {}
        end
        for _, v in pairs(msg.role_digests or {}) do
            self._role_digests[v.role_id] = v
        end
        self:fire(Game_User_Event.role_digiests_change, self)
    end
end

function GameUser:create_role(params)
    return self._app.net_mgr.game_gate_net:send_msg_to_gate(Login_Pid.req_create_role, { params = params })
end

function GameUser:_on_msg_rsp_create_role(pto_id, msg)
    log_debug("GameUser:on_msg_rsp_create_role %s %s", pto_id, msg)
    self:pull_role_digest(nil)
end

function GameUser:launch_role(role_id)
    if self._launch_role_id then
        return false
    end

    local ret = self._app.net_mgr.game_gate_net:send_msg_to_gate(Login_Pid.req_launch_role, { role_id = role_id } )
    if ret then
        self._last_try_launch_role_id = role_id
    end
    return ret
end

function GameUser:_on_msg_rsp_launch_role(pto_id, msg)
    log_debug("GameUser:on_msg_rsp_launch_role %s %s", pto_id, msg)
    if self._last_try_launch_role_id and self._last_try_launch_role_id == msg.role_id then
        if Error_None == msg.error_num then
            self._launch_role_id = self._last_try_launch_role_id
            self:_set_role_reachable(true)
        end
        self._last_try_launch_role_id = nil
        self:fire(Game_User_Event.launch_role, msg.error_num)
    end
end

function GameUser:logout_role()
    self._app.net_mgr.game_gate_net:send_msg_to_gate(Login_Pid.req_logout_role, role_id)
    self._launch_role_id = nil
    self:_set_role_reachable(false)
    self:fire(Game_User_Event.logout_role)
end

function GameUser:_on_msg_rsp_logout_role(pto_id, msg)

end

function GameUser:reconnect_role()
    if self._launch_role_id and self:get_role_reachable() then
        return false
    end
    local ret = self._app.net_mgr.game_gate_net:send_msg_to_gate(Login_Pid.req_reconnect_role, {
        role_id = self._launch_role_id, user_login_msg = {} })
    return ret
end

function GameUser:_on_msg_rsp_reconnect_role(pto_id, msg)
    if self._launch_role_id == msg.role_id then
        if Error_None == msg.error_num then
            self:_set_role_reachable(true)
        end
    end
end

function GameUser:_set_role_reachable(val)
    local old_val = self:get_role_reachable()
    self._is_role_reachable = val
    if old_val ~= self:get_role_reachable() then
        self:fire(Game_User_Event.role_reachable_change, self._is_role_reachable)
    end
end

function GameUser:get_role_reachable()
    if not self._launch_role_id then
        return false
    end
    if not self._is_role_reachable then
        return false
    end
    return true
end