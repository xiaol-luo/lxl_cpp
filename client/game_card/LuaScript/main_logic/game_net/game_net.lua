
GameNet = GameNet or class("GameNet")

function GameNet:ctor(open_cb, close_cb, recv_msg_cb)
    self.open_cb = open_cb
    self.close_cb = close_cb
    self.recv_msg_cb = recv_msg_cb
    self.natvie_game_net = CS.Utopia.LuaGameNet()
    self.natvie_game_net:SetLuaCallbacks(self.open_cb, self.close_cb, self.recv_msg_cb)
end

function GameNet:connect(host, port)
    return self.natvie_game_net:Connect(host, port)
end

function GameNet:close()
    self.natvie_game_net:Close()
end

function GameNet:get_state()
    return self.natvie_game_net:GetState()
end

function GameNet:send(proto_id, bin)
    if not bin then
        self.natvie_game_net:Send(proto_id)
    else
        self.natvie_game_net:Send(proto_id, bin, 0, #bin)
    end
end