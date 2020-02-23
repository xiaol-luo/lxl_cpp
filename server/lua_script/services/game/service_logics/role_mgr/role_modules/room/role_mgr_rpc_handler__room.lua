
_RpcRoleRoom = _RpcRoleRoom or {}

function RoleMgr:_setup_rpc_handler__room()
    self.rpc_mgr:set_req_msg_process_fn(GameRpcFn.notify_terminate_room, Functional.make_closure(_RpcRoleRoom._on_rpc_notify_terminate_room, self))
    self.rpc_mgr:set_req_msg_process_fn(GameRpcFn.notify_end_room, Functional.make_closure(_RpcRoleRoom._on_rpc_notify_end_room, self))
    self.rpc_mgr:set_req_msg_process_fn(GameRpcFn.notify_fight_start, Functional.make_closure(_RpcRoleRoom._on_rpc_notify_fight_start, self))
end


function _RpcRoleRoom._on_rpc_notify_terminate_room(role_mgr, rpc_rsp, room_id, role_id, session_id)
    rpc_rsp:respone()
    local role = role_mgr:get_in_game_role(role_id)
    if not role then
        return
    end
    if role.room.room_session_id ~= session_id then
        return
    end
    if role.room.room_id ~= room_id then
        return
    end
    role:send_to_client(ProtoId.notify_terminate_room, {
        session_id = role.room.room_session_id,
        room_id = role.room.room_id,
    })
    role.room:reset_room()
    role.room:sync_room_state()
end

function _RpcRoleRoom._on_rpc_notify_end_room(role_mgr, rpc_rsp, room_id, role_id, session_id, fight_result)
    rpc_rsp:respone()
    local role = role_mgr:get_in_game_role(role_id)
    if not role then
        return
    end
    if role.room.room_session_id ~= session_id then
        return
    end
    if role.room.room_id ~= room_id then
        return
    end
    role:send_to_client(ProtoId.notify_terminate_room, {
        session_id = role.room.room_session_id,
        room_id = role.room.room_id
    })
    role.room:reset_room()
    -- todo: give reward
    log_debug("_RpcRoleRoom._on_rpc_notify_end_room fight_result=%s", fight_result)
    role.room:sync_room_state()
end

function _RpcRoleRoom._on_rpc_notify_fight_start(role_mgr, rpc_rsp, room_id, role_id, session_id)
    rpc_rsp:respone()
    local role = role_mgr:get_in_game_role(role_id)
    if not role then
        return
    end
    if role.room.room_session_id ~= session_id then
        return
    end
    if role.room.room_id ~= room_id then
        return
    end
    role.room.is_fight_started = true
    role.room:sync_room_state()
end

