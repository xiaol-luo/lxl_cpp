
---@class GameUser:DataBase
GameUser = GameUser or class("GameUser", DataBase)

function GameUser:ctor(data_mgr)
    GameUser.super.ctor(self, data_mgr, "game_user")
    ---@type NetMgr
    self._net_mgr = self._app.net_mgr
    self._user_id = -1
    self._launch_role_id = -1
    self._role_digests = {}
end

function GameUser:_on_init()
    GameUser.super._on_init(self)
    self._event_binder:bind(self._app.net_mgr, Game_Net_Event.game_login_done,
            Functional.make_closure(self._on_event_game_login_done, self))
    self._event_binder:bind(self._app.net_mgr, Game_Net_Event.gate_connect_done,
            Functional.make_closure(self._on_event_gate_connect_done, self))
    log_print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!", Login_Pid.rsp_pull_role_digest)
    self._event_binder:bind(self._app.net_mgr, Login_Pid.rsp_pull_role_digest,
            Functional.make_closure(self._on_msg_rsp_pull_role_digest, self))
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

function GameUser:pull_role_digest(role_id)
    return self._app.net_mgr.game_gate_net:send_msg(Login_Pid.req_pull_role_digest, {role_id = role_id })
end

function GameUser:_on_msg_rsp_pull_role_digest(pto_id, msg)
    log_print("GameUser:on_msg_rsp_pull_role_digest 11111 xxx ", pto_id, "zzz", msg)
    if Error_None ==  msg.error_num then
        if 0 == msg.role_id then
            self.role_digests = {}
        else
            self.role_digests[msg.role_id] = {}
        end
        for _, v in pairs(msg.role_digests) do
            self._role_digests[v.role_id] = v
        end
        self:fire(Game_User_Event.role_digiests_change, self)
    end
end

function GameUser:create_role(params)
    return self._app.net_mgr.game_gate_net:send_msg(Login_Pid.req_create_role, { params = params })
end

function GameUser:on_msg_rsp_create_role(pto_id, msg)
    log_debug("GameUser:on_msg_rsp_create_role %s %s", pto_id, msg)
    self:pull_role_digest(nil)
end

function GameUser:launch_role(role_id)
    if self._launch_role_id then
        return false
    end
    if self._app.net_mgr.game_gate_net:send_msg(Login_Pid.req_launch_role, { role_id = role_id } ) then
        self._launch_role_id = role_id
    end
end

function GameUser:reconnect_role(role_id)
    return self._app.net_mgr.game_gate_net:send_msg(ProtoId.req_reconnect, {
        role_id = role_id,
        {

        }
    } )
end


function GameUser:on_msg_rsp_launch_role(pto_id, msg)
    log_debug("GameUser:on_msg_rsp_launch_role %s %s", pto_id, msg)
    self.launch_role_error_num = msg.error_num
    if 0 == msg.error_num then
        self.is_launched_role = true
    end

    self._app.event_mgr:fire(Game_User_Event.launch_role_result, msg.error_num)
    -- self._app.event_mgr:fire(Event_Set__Gate_Cnn_Logic.rsp_launch_role, self, msg)
    -- self:send_msg_to_game(ProtoId.pull_match_state)
    -- self:send_msg_to_game(ProtoId.pull_room_state)
    -- self:send_msg_to_game(ProtoId.pull_remote_room_state)
end

function GameUser:set_user_info(user_info)
    self.user_info = {}
    self.user_info.gate_ip = user_info.gate_ip
    self.user_info.gate_port = user_info.gate_port
    self.user_info.user_id = user_info.user_id
    self.user_info.auth_sn = user_info.auth_sn
    self.user_info.auth_ip = user_info.auth_ip
    self.user_info.auth_port = user_info.auth_port
    self.user_info.account_id = user_info.account_id
    self.user_info.app_id = user_info.app_id
end