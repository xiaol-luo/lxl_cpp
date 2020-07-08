
---@class PeerNetService: ServiceBase
PeerNetService = PeerNetService or class("PeerNetService", ServiceBase)

function PeerNetService:ctor(service_mgr, service_name)
    PeerNetService.super.ctor(self, service_mgr, service_name)
    ---@type NetListen
    self._listen_handler = nil
    self._next_unique_id = make_sequence(0)
    self._is_joined_cluster = false

    ---@type table<number, PeerNetCnnState>
    self._unique_id_to_cnn_states = {}
    ---@type table<string, PeerNetServerState>
    self._culster_server_states = {}
    ---@type table<string, table<string, PeerNetServerState>
    self._cluster_server_states_group_by_roles = {}

    ---@type ProtoParser
    self._pto_parser = self.server.pto_parser
    ---@type table<number, Fn_Peer_Net_Pto_Handle>
    self._pto_handle_fns = {}
end

function PeerNetService:_on_init()
    PeerNetService.super._on_init(self)

    self._pto_parser:load_files(Peer_Net_Pto.pto_files)
    self._pto_parser:setup_id_to_protos(Peer_Net_Pto.id_to_pto)
end

function PeerNetService:_on_start()
    PeerNetService.super._on_start(self)
    self.listen_handler = NetListen:new()
    self.listen_handler:set_gen_cnn_cb(Functional.make_closure(PeerNetService._make_accept_cnn, self))
    local advertise_peer_port = tonumber(self.server.init_setting.advertise_peer_port)
    local ret = Net.listen("0.0.0.0", advertise_peer_port, self.listen_handler)
    if not ret then
        self._error_num = -1
        self._error_msg = string.format("PeerNetService listen advertise_peer_port=%s fail", advertise_peer_port)
    else
        log_info("PeerNetService listen advertise_peer_port %s", advertise_peer_port)
    end

    self._event_binder:bind(self.server, Discovery_Service_Event.cluster_join_state_change,
            Functional.make_closure(self._on_event_cluster_join_state_change, self))
    self._event_binder:bind(self.server, Discovery_Service_Event.cluster_server_change,
            Functional.make_closure(self._on_event_cluster_server_change, self))
end

function PeerNetService:_on_stop()
    PeerNetService.super._on_stop(self)
    self._event_binder:release_all()
    self:_close_all_cnns()
end

function PeerNetService:_on_update()
    PeerNetService.super._on_update(self)

    -- for test
--[[    local now_sec = logic_sec()
    if nil == self._connect_server_last_sec or now_sec - self._connect_server_last_sec > 1 then
        self._connect_server_last_sec = now_sec
        self:send_msg(self.server.discovery:get_self_server_key(), 33, nil)
    end]]
end

function PeerNetService:_on_event_cluster_join_state_change(is_joined)
    local old_value = self._is_joined_cluster
    self._is_joined_cluster = is_joined
    if old_value and old_value ~= self._is_joined_cluster then
        -- self:_close_all_cnns()
    end
end

function PeerNetService:_on_event_cluster_server_change(action, old_server_data, new_server_data)
    -- _culster_server_states 的增减都在这里了控制了，可以放心地在这里写快速索引相关的内容
    local server_key = old_server_data and old_server_data.key or new_server_data.key
    local server_state = self._culster_server_states[server_key]
    if not server_state then
        if Discovery_Service_Const.cluster_server_leave == action then
            return
        end
        server_state = PeerNetServerState:new()
        self._culster_server_states[server_key] = server_state
        server_state.server_key = server_key
        server_state.server_role, server_state.server_name = extract_from_cluster_server_name(server_key)
        server_state.cluster_server_name = gen_cluster_server_name(server_state.server_role, server_state.server_role)
        if not server_state.server_role or #server_state.server_name <= 0
                or not server_state.server_name or not #server_state.server_name then
            log_error("PeerNetService:_on_event_cluster_server_change server_key invalid! server_key=%s, server_role=%s, server_name=%s",
                    server_key, server_state.server_role, server_state.server_name)
            return
        end
        ---@type RandomHash
        local role_server_states = self._cluster_server_states_group_by_roles[server_state.server_role]
        if not role_server_states then
            role_server_states = RandomHash:new()
            self._cluster_server_states_group_by_roles[server_state.server_role] = role_server_states
        end
        role_server_states:add(server_key, server_state)
    end

    if server_state.cnn_unique_id then
        self:_close_cnn(server_state.cnn_unique_id)
        server_state.cnn_unique_id = nil
    end
    if server_state.loop_cnn_unique_id then
        self:_close_cnn(server_state.loop_cnn_unique_id)
    end

    if Discovery_Service_Const.cluster_server_join == action then
        server_state.server_data = new_server_data
    end
    if Discovery_Service_Const.cluster_server_change == action then
        server_state.server_data = new_server_data
    end
    if Discovery_Service_Const.cluster_server_leave == action then
        self._culster_server_states[server_key] = nil
        ---@type RandomHash
        local role_server_states = self._cluster_server_states_group_by_roles[server_state.server_role]
        if role_server_states then
            role_server_states:remove(server_key)
        end
    end
end

function PeerNetService:_make_accept_cnn(listen_handler)
    local unique_id = self._next_unique_id()
    local cnn = PidBinCnn:new()
    cnn:set_open_cb(Functional.make_closure(PeerNetService._on_accept_cnn_open, self, unique_id))
    cnn:set_close_cb(Functional.make_closure(PeerNetService._on_accept_cnn_close, self, unique_id))
    cnn:set_recv_cb(Functional.make_closure(PeerNetService._on_accept_cnn_recv_msg, self, unique_id))

    local cnn_state = PeerNetCnnState:new()
    cnn_state.unique_id = unique_id
    cnn_state.cnn = cnn
    cnn_state.cnn_type = Peer_Net_Const.accept_cnn_type
    self._unique_id_to_cnn_states[unique_id] = cnn_state

    return cnn
end

function PeerNetService:_connect_server(server_key)
    if not self._is_joined_cluster then
        return nil
    end
    local server_state = self._culster_server_states[server_key]
    if not server_state or not server_state:is_joined_cluster() then
        return nil
    end
    if server_state:is_none_network() then
        local server_data = server_state.server_data
        local cnn, unique_id = self:_make_peer_cnn()
        local cnn_async_id = Net.connect_async(server_data.data.advertise_peer_ip, server_data.data.advertise_peer_port, cnn)

        local cnn_state = PeerNetCnnState:new()
        cnn_state.unique_id = unique_id
        cnn_state.cnn = cnn
        cnn_state.cnn_type = Peer_Net_Const.peer_cnn_type
        cnn_state.server_key = server_state.server_key
        cnn_state.server_id = server_data.data.cluster_server_id
        cnn_state.server_data = server_data
        cnn_state.cnn_async_id = cnn_async_id
        self._unique_id_to_cnn_states[unique_id] = cnn_state

        server_state.cnn_unique_id = unique_id
    end

    return server_state.cnn_unique_id
end

function PeerNetService:_make_peer_cnn()
    local unique_id = self._next_unique_id()
    local cnn = PidBinCnn:new()
    cnn:set_open_cb(Functional.make_closure(PeerNetService._on_peer_cnn_open, self, unique_id))
    cnn:set_close_cb(Functional.make_closure(PeerNetService._on_peer_cnn_close, self, unique_id))
    cnn:set_recv_cb(Functional.make_closure(PeerNetService._on_peer_cnn_recv_msg, self, unique_id))
    return cnn, unique_id
end

function PeerNetService:_close_cnn(unique_id)
    local cnn_state = self._unique_id_to_cnn_states[unique_id]
    self._unique_id_to_cnn_states[unique_id] = nil
    if cnn_state then
        if cnn_state.cnn then
            cnn_state.cnn:reset()
        end
        if cnn_state.cnn_async_id then
            Net.cancel_async(cnn_state.cnn_async_id)
        end
        if cnn_state.server_key then
            local server_state = self._culster_server_states[cnn_state.server_key]
            if server_state then
                if server_state.cnn_unique_id  and server_state.cnn_unique_id == unique_id then
                    server_state.cnn_unique_id = nil
                end
                if server_state.loop_cnn_unique_id  and server_state.loop_cnn_unique_id == unique_id then
                    server_state.loop_cnn_unique_id = nil
                end
            end
        end
    end
end

function PeerNetService:_disconnect_server(server_key)
    local server_state = self._culster_server_states[server_key]
    if server_state and server_state.cnn_unique_id  then
        self:_close_cnn(server_state.cnn_unique_id)
        server_state.cnn_unique_id = nil
    end
    if server_state and server_state.loop_cnn_unique_id  then
        self:_close_cnn(server_state.loop_cnn_unique_id)
        server_state.loop_cnn_unique_id = nil
    end
end

function PeerNetService:_close_all_cnns()
    for _, unique_cnn_id in ipairs(table.keys(self._unique_id_to_cnn_states)) do
        self:_close_cnn(unique_cnn_id)
    end
end

---@field pid number
---@field fn Fn_Peer_Net_Pto_Handle
function PeerNetService:set_pto_handle_fn(pid, fn)
    assert(is_number(pid))
    if fn then
        assert(is_function(fn))
        assert(not self._pto_handle_fns[pid])
    end
    self._pto_handle_fns[pid] = fn
end

function PeerNetService:random_server_key(server_role)
    local ret = nil
    if server_role then
        local role_server_states = self._cluster_server_states_group_by_roles[server_role]
        if role_server_states then
            local val, key = role_server_states:random()
            ret = key
        end
    end
    -- log_print("PeerNetService:random_server_key", server_role, ret)
    return ret
end

function PeerNetService:get_role_server_keys(server_role)
    local ret = {}
    if server_role then
        local role_server_states = self._cluster_server_states_group_by_roles[server_role]
        if role_server_states then
            for server_key, _ in pairs(role_server_states) do
                table.insert(ret, server_key)
            end
        end
    end
    return ret
end


