
MainLogic = MainLogic or class("MainLogic")

function MainLogic:ctor()

end

function MainLogic:init(arg)
    local pre_require_files = require("main_logic.main_logic_impl.pre_require_files")
    for _, v in pairs(pre_require_files) do
        require(v)
    end
end

function MainLogic:on_start()

end

function MainLogic:on_update()

end

function MainLogic:init_proto_parser()

end
