

function RoleRoom:init_process_client_msg()
    self.role:set_client_msg_process_fn(ProtoId.pull_room_state, Functional.make_closure(self._on_msg_pull_room_state, self))
    self.role:set_client_msg_process_fn(ProtoId.pull_remote_room_state, Functional.make_closure(self._on_msg_pull_remote_room_state, self))
end

function RoleRoom:_on_msg_pull_room_state(pid, msg)
    self:sync_room_state()
end

function RoleRoom:_on_msg_pull_remote_room_state(pid, msg)
    if Role_Room_State.in_room ~= self.state then
        self.role:send_to_client(ProtoId.sync_remote_room_state, {
            head = { error_num = Error.Pull_Remote_Room_State.game_role_not_in_room, }
        })
    end
    self.room_client:call(function(rpc_error_num, error_num, pid, msg)
        if Error_None == rpc_error_num and Error_None == error_num then
            self.role:send_to_client(pid, msg)
        else
            self.role:send_to_client(ProtoId.sync_remote_room_state, {
                head = { rpc_error_num = rpc_error_num, error_num = error_num, }
            })
        end
    end, RoomRpcFn.pull_room_state, self.room_id)
end
