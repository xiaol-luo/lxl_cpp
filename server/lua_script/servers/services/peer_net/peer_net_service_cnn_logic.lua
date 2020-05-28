
function PeerNetService:send_binary(cnn_unique_id, pid, bin)
    local cnn_state = self._unique_id_to_cnn_states[cnn_unique_id]
    if not cnn_state or false == cnn_state.is_ok then
        return false
    end
    if true == cnn_state.is_ok then
        cnn_state.cnn:send(pid, bin)
        return true
    end
    if nil == cnn_state.is_ok then
        table.insert(cnn_state.cached_pid_bins, { pid = pid, bin = bin })
        return true
    end
    return false
end

function PeerNetService:_on_peer_cnn_open(unique_id, cnn_handler, error_num)
    log_print("PeerNetService:_on_peer_cnn_open ", unique_id)
    local cnn_state = self._unique_id_to_cnn_states[unique_id]
    if cnn_state then
        cnn_state.cnn_async_id = nil
        if 0 ~= error_num then
            cnn_state.error_num = error_num
            self:_close_cnn(unique_id)
            cnn_state.is_ok = false
        else
            cnn_state.is_ok = true
--[[            local cached_pid_bins = cnn_state.cached_pid_bins
            cnn_state.cached_pid_bins = {}
            for _, v in ipairs(cached_pid_bins) do
                cnn_state.cnn:send(v.pid, v.bin)
            end]]

            -- 需要在这里完成互认
        end
    end
end

function PeerNetService:_on_peer_cnn_close(unique_id, cnn_handler, error_num)
    log_print("PeerNetService:_on_peer_cnn_close ", unique_id)
    self:_close_cnn(unique_id)
end

function PeerNetService:_on_peer_cnn_recv_msg(unique_id, cnn_handler, pid, bin)
    local cnn_state = self._unique_id_to_cnn_states[unique_id]
    if not cnn_state then
        return
    end

    cnn_state.recv_msg_counts = cnn_state.recv_msg_counts + 1
    if true == cnn_state.is_ok then

    end
    if false == cnn_state.is_ok then
        -- 应该不会来到这里
        self:_close_cnn(unique_id)
    end
    if nil == cnn_state.is_ok then
        -- 第一条协议也必须是互认协议，先完成互认，才能处理后续的协议
        -- todo: 互认
        if not cnn_state.is_ok then
            -- 互认失败了
            self:_close_cnn(unique_id)
        end
    end
end


function PeerNetService:_on_accept_cnn_open(unique_id, cnn_handler, error_num)
    log_print("PeerNetService:_on_accept_cnn_open ", unique_id)
end

function PeerNetService:_on_accept_cnn_close(unique_id, cnn_handler, error_num)
    self:_close_cnn(unique_id)
end

function PeerNetService:_on_accept_cnn_recv_msg(unique_id, cnn_handler, pid, bin)
    log_print("PeerNetService:_on_accept_cnn_recv_msg ", unique_id)
    local cnn_state = self._unique_id_to_cnn_states[unique_id]
    if not cnn_state then
        return
    end
end

