
Client = Client or class("Client")

function Client:ctor()
    self.cnn = nil
    self.state = ClientState.Free
end

