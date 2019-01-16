

tcp_cnn_logic = tcp_cnn_logic or {}

function tcp_cnn_logic.on_close() end
function tcp_cnn_logic.on_open() end
function tcp_cnn_logic.on_recv() end


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
end
