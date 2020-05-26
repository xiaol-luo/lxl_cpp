
FightBase = FightBase or class("FightBase")

function FightBase:ctor(fight_mgr, fight_type, fight_id, fight_session_id, room_id, room_client, match_cells)
    self.fight_mgr = fight_mgr
    self.fight_type = fight_type
    self.fight_id = fight_id
    self.fight_session_id = fight_session_id
    self.room_id = room_id
    self.room_client = room_client
    self.match_cells = match_cells
    self.netid_to_client_datas = {} -- netid-> { role_id, client }
    self.client_msg_handle_fn_names = {}
end

function FightBase:init()
    self:set_msg_handle_fn_name(ProtoId.req_quit_fight, "_on_msg_quit_fight")
    self:set_msg_handle_fn_name(ProtoId.pull_fight_state, "_on_msg_pull_fight_state")
    self:set_msg_handle_fn_name(ProtoId.req_fight_opera, "_on_msg_req_fight_opera")
    local error_num = self:_on_init()
    return error_num
end

function FightBase:on_room_notify_start()

end

function FightBase:update()
    self:_on_update()
end

function FightBase:bind_client(client, role_id, fight_session_id)
    if fight_session_id ~= self.fight_session_id then
        return Error.Bind_Fight.fight_session_not_fix
    end
    if Client_State.free ~= client.state then
        return Error.Bind_Fight.client_not_free
    end
    local old_client_data = nil
    for _, item in pairs(self.netid_to_client_datas) do
        if item.role_id == role_id then
            old_client_data = item
            break
        end
    end
    if old_client_data then
        -- Todo: 要优化的话，可考虑通知被顶号之类的
        self:unbind_client(old_client_data.client)
    end
    local client_data = {
        role_id = role_id,
        client = client,
    }
    client.state = Client_State.binded
    client.fight = self
    self.netid_to_client_datas[client.netid] = client_data
    self:_on_bind_client(client_data)
    return Error_None
end

function FightBase:unbind_client(client)
    local client_data = self.netid_to_client_datas[client.netid]
    client_data.client:release()
    if data then
        self:_on_unbind_client(client_data)
    end
    self.netid_to_client_datas[client.netid] = nil
end

function FightBase:set_msg_handle_fn_name(pid, fn_name)
    log_assert(is_number(pid)  and is_string(fn_name), "pid should be number and fn_name should be string")
    log_assert(not self.client_msg_handle_fn_names[pid], "pid=%s already set fn_name=%s",
            pid, self.client_msg_handle_fn_names[pid])
    self.client_msg_handle_fn_names[pid] = fn_name
end

function FightBase:wait_release()
    assert("should not reach here")
end

function FightBase:release()
    self:_on_release()
    for _, item in pairs(self.netid_to_client_datas) do
        item.client:release()
    end
end

function FightBase:get_fight_result()
    return {}
end

function FightBase:foreach_client(fn, ...)
    for _, client_data in pairs(self.netid_to_client_datas) do
        fn(client_data, ...)
    end
end

function FightBase:_on_init()
    return Error_None
end

function FightBase:_on_bind_client(client_data)

end

function FightBase:_on_unbind_client(client_data)

end

function FightBase:_on_update()

end

function FightBase:_on_release()

end

function FightBase:on_client_msg(client, pid, msg)
    local client_data = self.netid_to_client_datas[client.netid]
    if not client_data then
        return
    end

    local is_handle = false
    local fn_name = self.client_msg_handle_fn_names[pid]
    if fn_name then
        local fn = self[fn_name]
        if is_function(fn) then
            fn(self, client_data, pid, msg)
            is_handle = true
        end
    end
    log_debug("FightBase:on_client_msg is_handled=%s, client.netid=%s, pid=%s, msg=%s", is_handle, client.netid, pid, msg)
end

function FightBase:_on_msg_quit_fight(client_data, pid, msg)

end

function FightBase:_on_msg_pull_fight_state(client_data, pid, msg)

end

function FightBase:_on_msg_req_fight_opera(client_data, pid, msg)

end









