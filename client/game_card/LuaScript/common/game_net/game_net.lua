
GameNet = GameNet or class("GameNet")

function GameNet:ctor(open_cb, close_cb, recv_msg_cb)
    self.open_cb = open_cb
    self.close_cb = close_cb
    self.recv_msg_cb = recv_msg_cb
    self.native_game_net = CS.Utopia.LuaGameNet()
    self.native_game_net:SetLuaCallbacks(self.open_cb, self.close_cb, self.recv_msg_cb)
end

function GameNet:connect(host, port)
    return self.native_game_net:Connect(host, port)
end

function GameNet:close()
    self.native_game_net:Close()
end

function GameNet:get_state()
    return self.native_game_net:GetState()
end

function GameNet:get_error_num()
    return self.native_game_net:GetErrorNum()
end

function GameNet:get_error_msg()
    return self.native_game_net:GetErrorMsg()
end

function GameNet:send(proto_id, bin)
    if not bin then
        self.native_game_net:Send(proto_id)
    else
        self.native_game_net:Send(proto_id, bin, 0, #bin)
    end
end

function GameNet:send_msg(proto_id, msg_tb)
    local is_ok, bin = true, nil
    if IsTable(msg_tb) then
        is_ok, bin = g_ins.proto_parser:encode(proto_id, msg_tb)
    end
    if is_ok then
        self:send(proto_id, bin)
    else
        log_error("encode proto %s fail", g_ins.proto_parser:get_proto_desc(proto_id))
    end
end

function GameNet:release()
    if CSharpHelp.not_null(self.native_game_net) then
        self.native_game_net:SetLuaCallbacks(nil, nil, nil)
    end
    self.open_cb = nil
    self.close_cb = nil
    self.recv_msg_cb = nil
end