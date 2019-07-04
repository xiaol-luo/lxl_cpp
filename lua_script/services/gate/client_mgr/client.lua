
Client = Client or class("Client")

function Client:ctor()
    self.netid = nil
    self.cnn = nil
    self.state = ClientState.Free
    self.user_id = nil
    self.launch_role_id = nil
    self.world_client = nil
    self.world_session_id = nil
end

function Client:is_authed()
    return self.state > ClientState.Authing
end

function Client:is_alive()
    return self.state < ClientState.Releasing
end

function Client:is_ingame()
    return ClientState.In_Game == self.state
end

function Client:is_free()
    return ClientState.Free == self.state
end

function Client:is_authing()
    return ClientState.Authing == self.state
end

function Client:is_launching()
    return ClientState.Launch_Role == self.state
end

