
ServiceMain = ServiceMain or {}

g_http_service = nil

function ServiceMain.start()
    local require_files = require("services.test_listen.service_files")
    for _, v in ipairs(require_files) do
        require(v)
    end

    RoleManager.start(3234)
    g_http_service = HttpService:new()
    g_http_service:start(20481)
end