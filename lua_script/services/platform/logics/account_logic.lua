
AccountLogic = AccountLogic or class("AccountLogic")

AccountLogic_Const = {
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
    Err_Num = "err_num",
    Matched_Count = "matched_count",
    Content = "content",
    Uid = "uid",
}

local Alc = AccountLogic_Const

function AccountLogic:ctor(service_main)
    self.service_main = service_main
    self.db_client = self.service_main.db_client
    self.query_db = self.service_main.query_db
    self.timer_proxy = TimerProxy:new()
end

function AccountLogic:get_http_handle_fns()
    local ret = {}
    ret["/index"] = Functional.make_closure(AccountLogic.index, self)
    ret["/login"] = Functional.make_closure(AccountLogic.login, self)
    ret["/app_auth"] = Functional.make_closure(AccountLogic.app_auth, self)
    return ret
end

function AccountLogic:index(from_cnn_id, method, req_url, kv_params, body)
    local rsp_content = gen_http_rsp_content(200, "OK", kv_params["xxx"], {})
    Net.send(from_cnn_id, rsp_content)
    Net.close(from_cnn_id)
end

local rsp_client = function(cnn_id, tb)
    local body_str = rapidjson.encode(tb)
    Net.send(cnn_id, gen_http_rsp_content(200, "OK", body_str))
    Net.close(cnn_id)
end

function AccountLogic:login(from_cnn_id, method, req_url, kv_params, body)
    local user_name = kv_params[Alc.UserName]
    local pwd = kv_params[Alc.Pwd] or ""
    local appid = kv_params[Alc.Appid]

    local rsp_body = {}
    rsp_body.error = ""
    rsp_body[Alc.Appid] = appid
    rsp_body[Alc.UserName] = user_name
    rsp_body[Alc._Id] = nil
    rsp_body[Alc.Token] = nil
    rsp_body[Alc.Timestamp] = nil


    if not user_name or #user_name <= 0 or not appid or #appid < 0 then
        rsp_body.error = "invalid user name or appid"
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
        local co_ok = nil
        local filter = { [Alc.UserName]= user_name }
        local opt = MongoOptFind:new()
        opt:set_max_time(10 * 1000)
        opt:set_projection({ [Alc.UserName]=true, [Alc.Pwd]=true })
        local query_ret = nil
        co_ok, query_ret = self.db_client:co_find_one(1, self.query_db, Alc.Account, filter, opt)
        if not co_ok or 0 ~= query_ret[Alc.Err_Num] then
            report_error("co_find_one fail")
            return
        end
        if query_ret[Alc.Matched_Count] > 0 then
            -- rsp_body[Alc._Id] = query_ret[Alc.Val]["0"][Alc._Id][Alc._Oid]
        else
            local doc = {
                [Alc.UserName] = user_name,
                [Alc.Pwd] = pwd,
            }
            local co_ok, insert_account_ret = self.db_client:co_insert_one(1, self.query_db, Alc.Account, doc)
            if not co_ok or 0 ~= insert_account_ret[Alc.Err_Num] then
                report_error("insert account fail")
                return
            end
            -- rsp_body[Alc._Id] = insert_account_ret[Alc.Inserted_Ids][1]
        end

        local token_str = native.gen_uuid()
        local timestamp = os.time()
        local doc = {
            [Alc.Token] = token_str,
            [Alc.Appid] = appid,
            [Alc.UserName] = user_name,
            [Alc.Timestamp] = timestamp,
        }
        co_ok, insert_token_ret = self.db_client:co_insert_one(1, self.query_db, Alc.Token, doc)
        if 0 ~= insert_token_ret[Alc.Err_Num] then
            report_error("insert_token fail")
            return
        end
        rsp_body[Alc.Token] = token_str
        rsp_body[Alc.Timestamp] = timestamp
        rsp_client(from_cnn_id, rsp_body)
    end

    local over_fn = function(co_ex)
        -- local custom_data = co:get_custom_data()
        local return_vals = co_ex:get_return_vals()
        if not return_vals then
            rsp_body.error = co_ex:get_error_msg()
            rsp_client(from_cnn_id, rsp_body)
        end
        Net.close(from_cnn_id)
    end

    local co = ex_coroutine_create(main_logic, over_fn)
    ex_coroutine_expired(co,20 * 1000)
    ex_coroutine_start(co)
end

function AccountLogic:app_auth(from_cnn_id, method, req_url, kv_params, body)
    local token = kv_params[Alc.Token]
    local timestamp = kv_params[Alc.Timestamp]

    local rsp_body = {}
    rsp_body.error = ""
    rsp_body[Alc.Token] = token
    rsp_body[Alc.Timestamp] = timestamp

    if not token or #token <= 0 or not timestamp or #timestamp <= 0 then
        rsp_body.error = "invalid token or timestamp"
        rsp_client(from_cnn_id, rsp_body)
        return
    end

    local report_error = function(error_msg)
        rsp_body.error = error_msg or "unknown"
        rsp_client(from_cnn_id, rsp_body)
        local co_ex = ex_coroutine_running()
        if co_ex then
            ex_coroutine_report_error(error_msg)
        end
    end

    local main_logic = function()
        local co_ok = nil
        local filter = {
            [Alc.Token] = token,
            [Alc.Timestamp] = tonumber(timestamp),
        }
        local opt = MongoOptFind:new()
        opt:set_max_time(10 * 1000)
        local query_ret = nil
        co_ok, query_ret = self.db_client:co_find_one(1, self.query_db, Alc.Token, filter, opt)
        if not co_ok then
            local msg = query_ret
            report_error(msg)
            return
        end
        if query_ret[Alc.Matched_Count] <= 0 then
            report_error("not find matched token")
            return
        end

        -- log_debug("app_auth query_ret is %s", query_ret)
        local ret = query_ret[Alc.Val][tostring(0)]
        rsp_body[Alc.Appid] = ret[Alc.Appid]
        rsp_body[Alc.Uid] = ret[Alc._Id][Alc._Oid]
        -- rsp_body.content = query_ret[Alc.Val]
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
