
---@alias Fn_GameForwardHandleClientMsgFn fun(from_gate_server_key:string, gate_netid:number, role_id:number, pid:number, msg:table):void

---@class GameForwardMsg:GameLogicEntity
GameForwardMsg = GameForwardMsg or class("GameForwardMsg", GameLogicEntity)

function GameForwardMsg:ctor(logics, logic_name)
    GameForwardMsg.super.ctor(self, logics, logic_name)
    ---@type GameRoleMgr
    self._game_role_mgr = nil
    self._pto_parser = self.server.pto_parser
    ---@type table<number, Fn_GameForwardHandleClientMsgFn>
    self._client_msg_handle_fns = {}
end

function GameForwardMsg:_on_init()
    GameForwardMsg.super._on_init(self)
    self._game_role_mgr = self.logics.role_mgr
end

function GameForwardMsg:_on_start()
    GameForwardMsg.super._on_start(self)
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.game.method.forward_client_msg_to_game,
            Functional.make_closure(self._on_remote_call_forward_client_msg_to_game, self))
end

function GameForwardMsg:_on_stop()
    GameForwardMsg.super._on_stop(self)
end

function GameForwardMsg:_on_release()
    GameForwardMsg.super._on_release(self)
end

function GameForwardMsg:_on_update()

end

---@param handle_fn Fn_GameForwardHandleClientMsgFn
function GameForwardMsg:set_client_msg_handle_fn(pid, handle_fn)
    assert(pid)
    if handle_fn then
        assert(is_function(handle_fn))
        assert(not self._client_msg_handle_fns[pid])
    end
    self._client_msg_handle_fns[pid] = handle_fn
end

---@param rpc_rsp RpcRsp
function GameForwardMsg:_on_remote_call_forward_client_msg_to_game(rpc_rsp, gate_netid, role_id, msg)
    rpc_rsp:response()
    local game_role = self._game_role_mgr:get_role(role_id)
    if not game_role then
        return
    end
    local role_gate_server_key, role_gate_netid = game_role:get_gate()
    if rpc_rsp.from_host ~= role_gate_server_key or role_gate_netid ~= gate_netid then
        return
    end
    if Game_Role_State.in_game ~= game_role:get_state() then
        return
    end

    local further_forward = msg.further_forward -- todo: 想办法转发给别的server
    local pid = msg.pto_id
    local pto = nil
    if msg.pto_bytes and #msg.pto_bytes > 0 then
        local is_ok, tmp_pto = self._pto_parser:decode(pid, msg.pto_bytes)
        if is_ok then
            pto = tmp_pto
        else
            log_warn("GameForwardMsg:_on_remote_call_forward_client_msg_to_game decode pid:%s fail", pid)
            return
        end
    end

    local handle_fn = self._client_msg_handle_fns[pid]
    if not handle_fn then
        log_warn("GameForwardMsg:_on_remote_call_forward_client_msg_to_game not handle function for pid %s", pid)
        return
    end
    handle_fn(rpc_rsp.from_host, gate_netid, role_id, pid, pto)

    -- for test
    --[[
    self._rpc_svc_proxy:call(function(...)

    end, rpc_rsp.from_host, Rpc.gate.method.forward_msg_to_client, gate_netid, Login_Pid.rsp_pull_role_digest, { error_num = 0 })
    game_role.base_info:set_role_name("rand_role_name" .. tostring(math.random(1, 1000000)))
    ]]
end

function GameForwardMsg:send_msg_to_client(gate_server_key, gate_netid, pid, msg, cb_fn)
    if not gate_server_key or not gate_netid then
        return false
    end
    if not is_number(pid) then
        return false
    end

    local is_ok, bytes = true, nil
    if msg then
        is_ok, bytes = self.server.pto_parser:encode(pid, msg)
    end
    if not is_ok then
        log_warn("GameRole:send_msg encode fail, pid %s and msg %s", is_ok, msg)
        return
    end
    self.server.rpc:call(cb_fn, gate_server_key,
            Rpc.gate.method.forward_msg_to_client, gate_netid, pid, bytes)
    return true
end



