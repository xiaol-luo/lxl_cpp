
declare_event_set("Event_Set__Main_User", {
    "launch_role_result",
})

MainUser = MainUser or class("MainUser")

function MainUser:ctor(main_logic)
    self.main_logic = main_logic
    self.msg_event_subscriber = self.main_logic.msg_event_mgr:create_subscriber()
    self.event_subscriber = self.main_logic.event_mgr:create_subscriber()
    self.user_id = nil
    self.role_digests = {}
    self.launch_role_id = nil
end

function MainUser:init()
    self.msg_event_subscriber:subscribe(ProtoId.rsp_pull_role_digest, Functional.make_closure(self.on_msg_rsp_pull_role_digest, self))
    self.msg_event_subscriber:subscribe(ProtoId.rsp_create_role, Functional.make_closure(self.on_msg_rsp_create_role, self))
    self.msg_event_subscriber:subscribe(ProtoId.rsp_launch_role, Functional.make_closure(self.on_msg_rsp_launch_role, self))
end

function MainUser:pull_role_digest(role_id)
    return self.main_logic.gate_cnn_logic:send_msg(ProtoId.req_pull_role_digest, {role_id = role_id })
end

function MainUser:on_msg_rsp_pull_role_digest(proto_id, msg)
    log_debug("MainUser:on_msg_rsp_pull_role_digest %s %s", proto_id, msg)
    self.role_digests = msg.role_digests
    -- self.main_logic.event_mgr:fire(Event_Set__Gate_Cnn_Logic.rsp_role_digests, self, msg)
end

function MainUser:create_role(params)
    return self.main_logic.gate_cnn_logic:send_msg(ProtoId.req_create_role, { params = params })
end

function MainUser:on_msg_rsp_create_role(proto_id, msg)
    log_debug("MainUser:on_msg_rsp_create_role %s %s", proto_id, msg)
    self:pull_role_digest(nil)
end

function MainUser:launch_role(role_id)
    return self.main_logic.gate_cnn_logic:send_msg(ProtoId.req_launch_role, { role_id = role_id } )
end

function MainUser:on_msg_rsp_launch_role(proto_id, msg)
    log_debug("MainUser:on_msg_rsp_launch_role %s %s", proto_id, msg)
    self.launch_role_error_num = msg.error_num
    if 0 == msg.error_num then
        self.is_launched_role = true
    end

    self.main_logic.event_mgr:fire(Event_Set__Main_User.launch_role_result, msg.error_num)
    -- self.main_logic.event_mgr:fire(Event_Set__Gate_Cnn_Logic.rsp_launch_role, self, msg)
    -- self:send_msg_to_game(ProtoId.pull_match_state)
    -- self:send_msg_to_game(ProtoId.pull_room_state)
    -- self:send_msg_to_game(ProtoId.pull_remote_room_state)
end

function MainUser:set_user_info(user_info)
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