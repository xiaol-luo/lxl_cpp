
Client = Client or class("Client")

function Client:ctor()
    self.netid = nil
    self.cnn = nil
    self.state = Client_State.Free
    self.user_id = nil
    self.launch_role_id = nil
    self.game_client = nil
    self.world_client = nil
    self.world_role_session_id = nil
    self.token = nil
end

function Client:is_authed()
    return self.state > Client_State.Authing
end

function Client:is_alive()
    return self.state < Client_State.Releasing
end

function Client:is_ingame()
    return Client_State.In_Game == self.state
end

function Client:is_free()
    return Client_State.Free == self.state
end

function Client:is_authing()
    return Client_State.Authing == self.state
end

function Client:is_launching()
    return Client_State.Launch_Role == self.state
end

