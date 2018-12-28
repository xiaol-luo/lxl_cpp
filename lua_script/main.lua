
local pre_require_files = function()
    local files = require("require_files")
    for _, v in ipairs(files) do
        require(v)
    end
end

function start_script()
    require("util.util")
    -- util.append_lua_search_path("./libs")
    -- util.append_c_search_path("./dyn_libs")
    ret = util.parse_main_args(arg)
    util.use_parse_main_ret(ret)
    pre_require_files()
    print(ret)
    assert(ret.logic and ret.logic[1], "assert ret.logic can not be null")
    local logic_name = ret.logic[1]
    local logic_main_file = string.format("logics.%s.logic_main", logic_name)
    print(logic_main_file)
    require(logic_main_file)
    LogicMain.start()
end

start_script()