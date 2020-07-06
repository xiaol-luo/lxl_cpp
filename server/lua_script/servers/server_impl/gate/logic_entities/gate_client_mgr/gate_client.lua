---@class GateClient
---@field cnn ClientNetCnn
GateClient = GateClient or class("GateClient")

function GateClient:ctor(cnn)
    self.cnn = cnn
    self.netid = cnn.netid
    self.state = Gate_Client_State.free
    self.user_id = nil
    self.launch_role_id = nil
    self.game_client = nil
    self.world_client = nil
    self.world_role_session_id = nil
    self.token = nil
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

function GateClient:reset()
    if self.cnn then
        self.cnn:reset()
    end
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

