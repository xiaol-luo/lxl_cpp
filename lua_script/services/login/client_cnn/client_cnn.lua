
ClientCnn = ClientCnn or class("ClientCnn")

function ClientCnn:ctor()
    self.cnn = nil
    self.netid = nil
    self.last_recv_sec = 0
end