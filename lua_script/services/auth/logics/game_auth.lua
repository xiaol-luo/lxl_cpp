
GameAuth = GameAuth or class("GameAuth")

GameAuth_Const = {
    Account = "account",
    UserName = "username",
    Pwd = "pwd",
    _Oid = "$oid",
    Val = "val",
    Token = "token",
    _Id = "_id",
    Inserted_Ids = "inserted_ids",
    Timestamp = "timestamp",
    Appid = "appid",
    Err_Num = "error_num",
    Matched_Count = "matched_count",
    Content = "content",
    Uid = "uid",
    Platform = "platform",
    Host = "host",
    Auth_Method = "auth_method",
    OK = "OK",
}

local Gac = GameAuth_Const

function GameAuth:ctor(service_main)
    self.service_main = service_main
    self.timer_proxy = TimerProxy:new()
    self.platform_host = SERVICE_SETTING[Gac.Platform][Gac.Host]
    self.platform_auth_method = SERVICE_SETTING[Gac.Platform][Gac.Auth_Method]
    self.auth_cached = {}
end

function GameAuth:get_http_handle_fns()
    local ret = {}
    ret["/index"] = Functional.make_closure(GameAuth.index, self)
    ret["/login_auth"] = Functional.make_closure(GameAuth.login_auth, self)
    ret["/gate_auth"] = Functional.make_closure(GameAuth.gate_auth, self)
    return ret
end

function GameAuth:index(from_cnn_id, method, req_url, kv_params, body)
    log_debug("index %s", req_url)
    local rsp_content = gen_http_rsp_content(200, "OK", "", {})
    Net.send(from_cnn_id, rsp_content)
    Net.close(from_cnn_id)
end

local rsp_client = function(cnn_id, tb)
    local body_str = rapidjson.encode(tb)
    Net.send(cnn_id, gen_http_rsp_content(200, "OK", body_str))
    Net.close(cnn_id)
end

function GameAuth:login_auth(from_cnn_id, method, req_url, kv_params, body)
    log_debug("login_auth = %s", req_url)
    local token = kv_params[Gac.Token]

    local rsp_body = {}
    rsp_body.error = ""
    rsp_body[Gac.Token] = kv_params[Gac.Token]
    rsp_body.uid = nil

    if not token or #token <= 0 then
        rsp_body.error = "token invalid"
        rsp_client(from_cnn_id, rsp_body)
        return
    end

    local report_error = function(error_msg)
        rsp_body.error = error_msg or "unknown"
        rsp_client(from_cnn_id, rsp_body)
        local co_ex = ex_coroutine_running()
        if co_ex then
            ex_coroutine_report_error(co_ex, error_msg)
        end
    end

    local main_logic = function()
        log_debug("main_logic 1")
        local url = string.format("http://%s/%s", self.platform_host, self.platform_auth_method)
        log_debug("main_logic 2")
        local url_params = {}
        for _, key in ipairs({ Gac.Token }) do
            table.insert(url_params, string.format("%s=%s", key, kv_params[key]))
        end
        log_debug("main_logic 3")
        local url_query = string.format("%s?%s", url, table.concat(url_params,"&"))
        log_debug("url_query is %s", url_query)
        local co_ok, http_ret = HttpClient.co_get(url_query, {})
        if not co_ok then
            report_error(string.format("query platform fail %s", "logic raise error"))
            return
        end
        local rsp_state, body_str = http_ret.state, http_ret.body
        if Gac.OK ~= rsp_state then
            report_error(string.format("query platform fail http respone state: %s", rsp_state))
            return
        end
        log_debug("main_logic 5")
        local ret = rapidjson.decode(body_str)
        log_debug("query result is %s", ret)
        rsp_body[Gac.Uid] = ret[Gac.Uid]
        rsp_body[Gac.Appid] = ret[Gac.Appid]
        rsp_client(from_cnn_id, rsp_body)
    end

    local over_fn = function(co_ex)
        local returnn_vals = co_ex:get_return_vals()
        if not returnn_vals then
            rsp_body.error = co_ex:get_error_msg() or "unknown"
            rsp_client(from_cnn_id, rsp_body)
        end
        Net.close(from_cnn_id)
    end
    local co = ex_coroutine_create(main_logic, over_fn)
    ex_coroutine_expired(co, 30 * 1000)
    ex_coroutine_start(co)
end

function GameAuth:gate_auth(from_cnn_id, method, req_url, kv_params, body)
    self:login_auth(from_cnn_id, method, req_url, kv_params, body)
end
