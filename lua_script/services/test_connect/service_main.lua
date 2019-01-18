
ServiceMain = ServiceMain or {}

function ServiceMain.start()
    local require_files = require("services.test_connect.service_files")
    for _, v in ipairs(require_files) do
        require(v)
    end

    RoleRobot.start(3234)
end