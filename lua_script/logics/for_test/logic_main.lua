

tcp_cnn_logic = tcp_cnn_logic or {}

function tcp_cnn_logic.on_close()

end
function tcp_cnn_logic.on_open()

end
function tcp_cnn_logic.on_recv()

end

g_listen_handler = nil
g_cnn_handler_connect = nil
g_cnn_handler_accept = nil


function test_net_open(t, err_num)
    print("test_net_open t", t:netid())
    print("test_net_open err_num", err_num)
end

function test_net_close(t, err_num)
    print("test_net_close t", t:netid())
    print("test_net_close err_num", err_num)
end


function test_net_recv(t, pid, bin)
    print("test_net_recv t", t:netid())
    print("test_net_recv pid", pid)
    print("test_net_recv bin", bin)
end

function test_net_gen_cnn(t)
    -- print("test_net_gen_cnn t", t)
    print("test_net_gen_cnn t", t:netid())
    local cnn = TcpConnect:new()
    cnn:set_recv_cb(test_net_recv)
    cnn:set_open_cb(test_net_open)
    cnn:set_close_cb(test_net_close)
    g_cnn_handler_accept = cnn
    return cnn
end

function test_send(pid)
    if g_cnn_handler_connect then
        g_cnn_handler_connect:send(pid, "hello world")
    end
end

LogicMain = {}
function LogicMain.start()
    print("this is logic for_test")

    -- test tryuselualib
    tryuselualib.log_msg("1234")
    othertryuselualib.log_msg("3345")

    print("work dir is ", lfs.currentdir())
    -- lfs.chdir(lfs.currentdir() .. "/..")
    -- print("work dir is ", lfs.currentdir())

    xml.print_table(LOGIC_SETTING)

    local cnn = native.LuaTcpConnect:new()
    local ret = cnn:init(tcp_cnn_logic)
    print("xxx", ret)
    print(cnn)

    g_listen_handler = TcpListen:new()
    g_listen_handler:set_open_cb(test_net_open)
    g_listen_handler:set_close_cb(test_net_close)
    g_listen_handler:set_gen_cnn_cb(test_net_gen_cnn)
    native.net_listen("0.0.0.0", 1234, g_listen_handler:get_native_listen_weak_ptr())

    g_cnn_handler_connect = TcpConnect:new()
    g_cnn_handler_connect:set_open_cb(test_net_open)
    g_cnn_handler_connect:set_close_cb(test_net_close)
    g_cnn_handler_connect:set_recv_cb(test_net_recv)
    print("hello worl xxxxx here")
    native.net_connect("127.0.0.1", 1234, g_cnn_handler_connect:get_native_connect_weak_ptr())
    print("hello worl xxxxx here 2")
    g_cnn_handler_connect:send(1, "hello world")
    print("hello worl xxxxx here 3")
end
