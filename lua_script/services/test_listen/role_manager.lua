
RoleManager = RoleManager or {}

RoleManager.listen_handler = nil
RoleManager.roles = {}



function RoleManager.start(listen_port)
    RoleManager.listen_handler = TcpListen:new()
    RoleManager.listen_handler:set_gen_cnn_cb(RoleManager.listen_gen_cnn)
    RoleManager.listen_handler:set_open_cb(RoleManager.on_listen_open)
    RoleManager.listen_handler:set_close_cb(RoleManager.on_listen_close)
    local netid = native.net_listen("0.0.0.0", listen_port, RoleManager.listen_handler:get_native_listen_weak_ptr())
    print("RoleManager.start ", listen_port, netid)
    return netid > 0
end

function RoleManager.stop()

end

function RoleManager.on_listen_open(t, err_num)
    print("RoleManager.on_listen_open")
end

function RoleManager.on_listen_close(t, err_num)
    print("RoleManager.on_listen_close")
end

function RoleManager.listen_gen_cnn(t)
    local cnn = TcpConnect:new()
    cnn:set_open_cb(RoleManager.on_cnn_open)
    cnn:set_close_cb(RoleManager.on_cnn_close)
    cnn:set_recv_cb(RoleManager.on_cnn_recv)
    return cnn
end

function RoleManager.on_cnn_open(t, err_num)
    print("RoleManager.on_cnn_open", t:netid())
    if 0 == err_num then
        RoleManager.roles[t:netid()] = t
    end
end

function RoleManager.on_cnn_close(t, err_num)
    print("RoleManager.on_cnn_close")
    RoleManager.roles[t:netid()] = nil
end

function RoleManager.on_cnn_recv(t, pid, bin)
    print("RoleManager.on_cnn_recv", t:netid(), pid, bin)
    t:send(pid, bin)
end