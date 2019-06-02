
Client = Client or class("Client")

function Client:ctor()
    self.netid = nil
    self.cnn = nil
    self.state = ClientState.Free
    self.user_id = nil
end

