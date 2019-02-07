
ServiceMain = ServiceMain or {}

function http_rsp_cb(...)
    print("http_rsp_cb")
end

function http_event_cb(...)
    print("http_event_cb")
end

function try_connect()       
    -- native.http_get("127.0.0.1:20481/xxxxx", http_rsp_cb, http_event_cb)
    native.http_get("https://www.baidu.com/s?ie=utf-8&f=3&rsv_bp=0&rsv_idx=1&tn=baidu&wd=a&rsv_pq=bb141cd50005c29e&rsv_t=d4be7%2BIoOy6ZMDudji4hJdyIrtGS8SHXPRSWu9ub3XNpZ31mv%2FNLcvwczCE&rqlang=cn&rsv_enter=0&rsv_sug3=2&rsv_sug1=2&rsv_sug7=101&prefixsug=a&rsp=0&inputT=2086&rsv_sug4=2320", http_rsp_cb, http_event_cb)
end

function ServiceMain.start()
    local require_files = require("services.test_connect.service_files")
    for _, v in ipairs(require_files) do
        require(v)
    end

    -- RoleRobot.start(3234)
    native.timer_firm(try_connect, 5000, 10000)
end
