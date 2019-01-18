
RoleRobot = RoleRobot or {}

local roles = {}

function RoleRobot.start(listen_port)
    native.timer_firm(RoleRobot.on_tick, 1000, -1)
end

function RoleRobot.stop()

end

function RoleRobot.on_tick()
    print("RoleRobot.on_tick")

    local cnn_handler = RoleRobot.gen_cnn()
    native.net_connect("127.0.0.1", 3234, cnn_handler:get_native_connect_weak_ptr())

    local roles_size = 0
    for k, v in pairs(roles) do
        local send_str = "I am robot number " .. v:netid()
        v:send(1, send_str)
        roles_size = roles_size + 1
    end
    if roles_size > 30 then
        for _, v in pairs(roles) do
            native.net_close(v:netid())
        end
        roles = {}
    end
end

function RoleRobot.gen_cnn(t)
    local cnn = TcpConnect:new()
    cnn:set_open_cb(RoleRobot.on_cnn_open)
    cnn:set_close_cb(RoleRobot.on_cnn_close)
    cnn:set_recv_cb(RoleRobot.on_cnn_recv)
    return cnn
end

function RoleRobot.on_cnn_open(t, err_num)
    -- print("RoleRobot.on_cnn_open", t:netid())
    if 0 == err_num then
        roles[t:netid()] = t
    end
end

function RoleRobot.on_cnn_close(t, err_num)
    print("RoleRobot.on_cnn_close")
    roles[t:netid()] = nil
end

function RoleRobot.on_cnn_recv(t, pid, bin)
    print("RoleRobot.on_cnn_recv", t:netid(), pid, bin)
end