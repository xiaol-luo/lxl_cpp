
function ClientMgr:setup_proto_handler()
    self.client_cnn_mgr:set_default_process_fn(Functional.make_closure(self._default_hanle_msg_fn, self))
    self.client_cnn_mgr:set_process_fn(ProtoId.req_bind_fight, Functional.make_closure(self._on_msg_req_bind_fight, self))
    self.client_cnn_mgr:set_process_fn(ProtoId.req_quit_fight, Functional.make_closure(self._on_msg_req_quit_fight, self))
end

function ClientMgr:_default_hanle_msg_fn(netid, pid, msg)
    if pid > ProtoId.fight_logic_min_pid and pid < ProtoId.fight_logic_max_pid then
        local client = self.clients[netid]
        if client then
            if Client_State.binded == client.state and client.fight then
                client.fight:on_client_msg(client, pid, msg)
            else
                log_error("ClientMgr:_default_hanle_msg_fn netid=%s, pid=%s client not binded", netid, pid)
            end
        else
            log_error("ClientMgr:_default_hanle_msg_fn netid=%s, pid=%s, unexpected error for not find client", netid, pid)
        end
        return
    end
    log_debug("ClientMgr:_default_hanle_msg_fn no process fn for pid=%s, netid=%s", pid, netid)
end

function ClientMgr:_on_msg_req_bind_fight(netid, pid, msg)
    local error_num = Error_Unknown
    repeat
        local client = self.clients[netid]
        if not client then
            error_num = Error.Bind_Fight.no_client
            break
        end
        if Client_State.free ~= client.state then
            error_num = Error.Bind_Fight.client_binded
            break
        end
        local fight = self.service.fight_mgr:get_fight(msg.fight_id)
        if not fight then
            error_num = Error.Bind_Fight.fight_not_exist
            break
        end
        error_num = fight:bind_client(client, msg.role_id, msg.fight_session_id)
    until true
    self:send(netid, ProtoId.rsp_bind_fight, { error_num = error_num })
end



