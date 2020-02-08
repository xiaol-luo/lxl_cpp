
MainRole = MainRole or class("MainRole")

function MainRole:ctor(main_logic)
    self.main_logic = main_logic
    self.event_subscriber = self.main_logic.msg_event_mgr:create_subscriber()
    self.role_id = nil
    self.user_id = nil
    self.data_role_msg = nil
    self.data_match_msg = nil
    self.data_room_msg = nil
end

function MainRole:init()
    self.event_subscriber:subscribe(ProtoId.sync_role_data, Functional.make_closure(self._on_msg_sync_role_data, self))
    self.event_subscriber:subscribe(ProtoId.rsp_join_match, Functional.make_closure(self._on_msg_rsp_join_match, self))
    self.event_subscriber:subscribe(ProtoId.sync_match_state, Functional.make_closure(self._on_msg_sync_match_state, self))
    self.event_subscriber:subscribe(ProtoId.rsp_quit_match, Functional.make_closure(self._on_msg_rsp_quit_match, self))
    self.event_subscriber:subscribe(ProtoId.sync_room_state, Functional.make_closure(self._on_msg_sync_room_state, self))
    self.event_subscriber:subscribe(ProtoId.sync_remote_room_state, Functional.make_closure(self._on_msg_sync_remote_room_state, self))
end

function MainRole:update_data(msg)
    self.role_data_msg = msg
    if msg then
        self.user_id = msg.user_id
        self.role_id = msg.role_id
        self.role_name = msg.base_info.role_name
    end
end

function MainRole:_on_msg_sync_role_data(proto_id, msg)
    log_debug("MainRole:_on_msg_sync_role_data %s  xx %s", proto_id, msg)
    self:update_data(msg)
end

function MainRole:_on_msg_rsp_join_match(proto_id, msg)
    log_debug("MainRole:_on_msg_rsp_join_match %s  xx %s", proto_id, msg)
end

function MainRole:_on_msg_rsp_quit_match(proto_id, msg)
    log_debug("MainRole:_on_msg_rsp_quit_match %s  xx %s", proto_id, msg)
end

function MainRole:_on_msg_sync_match_state(proto_id, msg)
    log_debug("MainRole:_on_msg_sync_match_state %s  xx %s", proto_id, msg)
    self.data_match_msg = msg
end

function MainRole:_on_msg_sync_room_state(proto_id, msg)
    log_debug("MainRole:_on_msg_sync_room_state %s  xx %s", proto_id, msg)
    self.data_room_msg = msg
end

function MainRole:_on_msg_sync_remote_room_state(proto_id, msg)
    log_debug("MainRole:_on_msg_sync_remote_room_state %s  xx %s", proto_id, msg)
    -- self.data_room_msg = msg
end




