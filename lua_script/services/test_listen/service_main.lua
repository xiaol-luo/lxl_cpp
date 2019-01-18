
ServiceMain = ServiceMain or {}

function ServiceMain.start()
    local require_files = require("services.test_listen.service_files")
    for _, v in ipairs(require_files) do
        require(v)
    end

    RoleManager.start(3234)
end