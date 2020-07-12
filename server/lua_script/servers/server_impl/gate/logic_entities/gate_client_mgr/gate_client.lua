---@class GateClient
---@field cnn ClientNetCnn
GateClient = GateClient or class("GateClient")

function GateClient:ctor(cnn)
    self.cnn = cnn
    self.netid = cnn.netid
    self.state = Gate_Client_State.free
    self.user_id = nil
    self.auth_sn = nil
    self.role_id = nil
    self.game_server_key = nil
    self.session_id = nil
end

function GateClient:send_bin(pid, bin)
    if self.cnn then
        return self.cnn:send_bin(pid, bin)
    end
    return false
end

function GateClient:send_msg(pid, msg)
    if self.cnn then
        return self.cnn:send_msg(pid, msg)
    end
    return false
end

function GateClient:Disconnect()
    if self.cnn then
        Net.close(self.netid)
    end
    log_print("GateClient:Disconnect ", debug.traceback())
end

function GateClient:is_authed()
    return self.state > Gate_Client_State.authing
end

function GateClient:is_alive()
    return self.state < Gate_Client_State.releasing
end

function GateClient:is_ingame()
    return Gate_Client_State.in_game == self.state
end

function GateClient:is_free()
    return Gate_Client_State.free == self.state
end

function GateClient:is_authing()
    return Gate_Client_State.authing == self.state
end

function GateClient:is_launching()
    return Gate_Client_State.launch_role == self.state
end

