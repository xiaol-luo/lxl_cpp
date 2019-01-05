
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
end