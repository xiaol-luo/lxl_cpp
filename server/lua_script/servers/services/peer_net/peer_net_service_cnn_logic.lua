
-- function PeerNetService:send_msg_with_server_key(server_key, pid, msg_tb)
function PeerNetService:send_msg(server_key, pid, msg_tb)
    local is_ok, bin = true, nil
    if is_table(msg_tb) then
        is_ok, bin = self._pto_parser:encode(pid, msg_tb)
    end
    if is_ok then
       is_ok = self:send_binary(server_key, pid, bin)
    end
    return is_ok
end

-- function PeerNetService:send_binary_with_server_key(server_key, pid, bin)
function PeerNetService:send_binary(server_key, pid, bin)
    local server_state = self._culster_server_states[server_key]
    if not server_state or not server_state:is_joined_cluster() then
        return false
    end
    if not server_state.cnn_unique_id then
        local ret = self:_connect_server(server_state.server_key)
        if not ret then
            return false
        end
    end
    return self:send_binary_with_id(server_state.cnn_unique_id, pid, bin)
end

function PeerNetService:send_msg_with_id(cnn_unique_id, pid, msg_tb)
    local is_ok, bin = true, nil
    if is_table(msg_tb) then
        is_ok, bin = self._pto_parser:encode(pid, msg_tb)
    end
    if is_ok then
        is_ok = self:send_binary_with_id(cnn_unique_id, pid, bin)
    end
    return is_ok
end

function PeerNetService:send_binary_with_id(cnn_unique_id, pid, bin)
    local cnn_state = self._unique_id_to_cnn_states[cnn_unique_id]
    if not cnn_state or false == cnn_state.is_ok then
        return false
    end
    if true == cnn_state.is_ok then
        return cnn_state.cnn:send(pid, bin)
    end
    if nil == cnn_state.is_ok then
        table.insert(cnn_state.cached_pid_bins, { pid = pid, bin = bin })
        return true
    end
    return false
end

function PeerNetService:_send_msg_help(cnn, pid, msg_tb)
    local is_ok, bin = true, nil
    if is_table(msg_tb) then
        is_ok, bin = self._pto_parser:encode(pid, msg_tb)
    end
    if is_ok then
        is_ok = cnn:send(pid, bin)
    end
    return is_ok
end

function PeerNetService:_on_peer_cnn_open(unique_id, cnn, error_num)
    -- log_print("PeerNetService:_on_peer_cnn_open 1", unique_id, error_num)
    local cnn_state = self._unique_id_to_cnn_states[unique_id]
    if cnn_state then
        cnn_state.cnn_async_id = nil
        if 0 ~= error_num then
            cnn_state.error_num = error_num
            cnn_state.is_ok = false
            self:_close_cnn(unique_id)
        else
            -- cnn_state.is_ok = true
            -- 需要在这里完成互认
            local server_state = self._culster_server_states[cnn_state.server_key]
            if server_state and unique_id == server_state.cnn_unique_id then
                self:_send_msg_help(cnn_state.cnn, Peer_Net_Pid.req_handshake, {
                    to_server_key = cnn_state.server_key,
                    to_cluster_server_id = cnn_state.server_data.data.cluster_server_id,
                    from_server_key = self.server:get_cluster_server_key(),
                    from_cluster_server_id = self.server:get_cluster_server_id(),
                })
            else
                cnn_state.is_ok = false
                self:_close_cnn(unique_id)
            end
        end
    end
end

function PeerNetService:_on_peer_cnn_close(unique_id, cnn, error_num)
    -- log_print("PeerNetService:_on_peer_cnn_close ", unique_id)
    self:_close_cnn(unique_id)
end

function PeerNetService:_on_peer_cnn_recv_msg(unique_id, cnn, pid, bin)
    local cnn_state = self._unique_id_to_cnn_states[unique_id]
    -- -- log_print("PeerNetService:_on_peer_cnn_recv_msg", pid, cnn_state)
    if not cnn_state then
        return
    end

    cnn_state.recv_msg_counts = cnn_state.recv_msg_counts + 1
    local is_ok, msg = self._pto_parser:decode(pid, bin)

    if true == cnn_state.is_ok then
        self:_on_cnn_recv_msg(pid, msg, unique_id, cnn_state.server_key, cnn_state.server_id)
        return
    end
    if false == cnn_state.is_ok then
        -- 应该不会来到这里
        self:_close_cnn(unique_id)
    end
    if nil == cnn_state.is_ok then
        -- 第一条协议也必须是互认协议，先完成互认，才能处理后续的协议
        local is_handshake_succ = false
        if is_ok and self._is_joined_cluster then
            if Peer_Net_Pid.rsp_handshake == pid and 0 == msg.error_num then
                local server_state = self._culster_server_states[cnn_state.server_key]
                if server_state and server_state.cnn_unique_id == unique_id then
                    is_handshake_succ = true
                end
            end
        end
        cnn_state.is_ok = is_handshake_succ
        if not is_handshake_succ then
            self:_close_cnn(unique_id)
        else
            for _, v in ipairs(cnn_state.cached_pid_bins) do
                cnn_state.cnn:send(v.pid, v.bin)
            end
            cnn_state.cached_pid_bins = {}
        end
    end
end

function PeerNetService:_on_accept_cnn_open(unique_id, cnn, error_num)
    -- log_print("PeerNetService:_on_accept_cnn_open ", unique_id, error_num)
end

function PeerNetService:_on_accept_cnn_close(unique_id, cnn, error_num)
    -- log_print("PeerNetService:_on_accept_cnn_close ", unique_id, error_num)
    self:_close_cnn(unique_id)
end

function PeerNetService:_on_accept_cnn_recv_msg(unique_id, cnn, pid, bin)
    local cnn_state = self._unique_id_to_cnn_states[unique_id]
    if not cnn_state or false == cnn_state.is_ok then
        return
    end

    cnn_state.recv_msg_counts = cnn_state.recv_msg_counts + 1
    local is_ok, msg = self._pto_parser:decode(pid, bin)

    if true == cnn_state.is_ok then
        self:_on_cnn_recv_msg(pid, msg, unique_id, cnn_state.server_key, cnn_state.server_id)
        return
    end

    if nil == cnn_state.is_ok then
        local is_handshake_succ = false
        if is_ok and self._is_joined_cluster then
            if Peer_Net_Pid.req_handshake == pid then
                if self.server:get_cluster_server_key() == msg.to_server_key and self.server:get_cluster_server_id() == msg.to_cluster_server_id then
                    local from_server_state = self._culster_server_states[msg.from_server_key]
                    if from_server_state  and  from_server_state:get_cluster_server_id() == msg.from_cluster_server_id then
                        -- 到此为止，集群上服务器信息已经对上了，下边要处理两种情况，且要考虑是否已经有连接已经存在得情况
                        -- 1.如果是自己连自己，那么在loop_cnn_unique_id未被占用（之前未有连接存在）就认为互认成功,否则直接放弃
                        -- 2.如果非自己连自己，那么在cnn_unique_id未被占用（之前未有连接存在）就认为互认成功，如果已经被占用，保留小的cluster_server_id对应的连接(以后要观察这种策略会不会造成问题)
                        if msg.to_cluster_server_id == msg.from_cluster_server_id then
                            if not from_server_state.loop_cnn_unique_id then
                                from_server_state.loop_cnn_unique_id = unique_id
                                is_handshake_succ = true
                            end
                        else
                            if from_server_state.cnn_unique_id then
                                local self_cluster_server_id = tonumber(self.server:get_cluster_server_id())
                                local from_cluster_server_id = tonumber(msg.from_cluster_server_id)
                                if from_cluster_server_id < self_cluster_server_id then -- 保留小的cluster_server_id对应的连接
                                    self:_close_cnn(from_server_state.cnn_unique_id)
                                    from_server_state.cnn_unique_id = unique_id
                                    is_handshake_succ = true
                                end
                            else
                                from_server_state.cnn_unique_id = unique_id
                                is_handshake_succ = true
                            end
                        end
                        cnn_state.server_key = from_server_state.server_key
                        cnn_state.server_id  = from_server_state.server_data.data.cluster_server_id
                        cnn_state.server_data = from_server_state.server_data
                    end
                end
            end
        end
        cnn_state.is_ok = is_handshake_succ
        self:_send_msg_help(cnn, Peer_Net_Pid.rsp_handshake, {
            error_num = is_handshake_succ and 0 or -1,
            error_msg = "",
        })
        if not is_handshake_succ then
            self:_close_cnn(unique_id)
        else
            for _, v in ipairs(cnn_state.cached_pid_bins) do
                cnn_state.cnn:send(v.pid, v.bin)
            end
            cnn_state.cached_pid_bins = {}
        end
        return
    end
end

function PeerNetService:_on_cnn_recv_msg(pid, msg, unique_id, from_server_key, from_server_id)
    local handle_fn = self._pto_handle_fns[pid]
    if not handle_fn then
        log_warn("PeerNetService:_on_cnn_recv_msg not handle function for pid=%s, msg from server_key=%s", pid, from_server_key)
        return false
    end
    local ret, error_msg = Functional.safe_call(handle_fn, pid, msg, unique_id, from_server_key, from_server_id)
    if not ret then
        log_error("PeerNetService:_on_cnn_recv_msg call handle fn fail! reason is %s", error_msg)
    end
    return ret
end

