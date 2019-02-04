
ServiceMain = ServiceMain or {}

function http_rsp_cb(...)
    print("http_rsp_cb")
end

function http_event_cb(...)
    print("http_event_cb")
end

function try_connect()
    native.http_get("127.0.0.1:20480/xxxxx", http_rsp_cb, http_event_cb)
end

function ServiceMain.start()
    local require_files = require("services.test_connect.service_files")
    for _, v in ipairs(require_files) do
        require(v)
    end

    -- RoleRobot.start(3234)
    native.timer_firm(try_connect, 5000, 10000)
end