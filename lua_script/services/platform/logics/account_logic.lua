
AccountLogic = AccountLogic or class("AccountLogic")

AccountLogic_Const = {
    Account = "account",
    UserName = "username",
    Pwd = "pwd",
    Oid = "Oid",
    Val = "val",
    Token = "token",
    _Id = "_id",
    Inserted_Ids = "inserted_ids",
    Timestamp = "timestamp",
    Appid = "appid",
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

    local body_tb = {}
    body_tb.error = ""
    body_tb[Alc.Appid] = appid
    body_tb[Alc.UserName] = user_name
    body_tb[Alc._Id] = nil
    body_tb[Alc.Token] = nil
    body_tb[Alc.Timestamp] = nil


    if not user_name or #user_name <= 0 or not appid or #appid < 0 then
        body_tb.error = "invalid user name or appid"
        rsp_client(from_cnn_id, body_tb)
        return
    end

    local report_error = function(error_msg)
        body_tb.error = error_msg or "unknown"
        rsp_client(from_cnn_id, body_tb)
        local co_ex = ex_coroutine_running()
        if co_ex then
            ex_coroutine_report_error(co, error_msg)
        end
    end

    local fn = function()
        local co_ok = nil
        local filter = { [Alc.UserName]= user_name }
        local opt = MongoOptFind:new()
        opt:set_max_time(10 * 1000)
        opt:set_projection({ [Alc.UserName]=true, [Alc.Pwd]=true })
        co_ok, query_ret = self.db_client:co_find_one(1, self.query_db, Alc.Account, filter, opt)
        if not co_ok or 0 ~= query_ret["err_num"] then
            report_error("co_find_one fail")
            return
        end
        if query_ret["matched_count"] > 0 then
            body_tb[Alc._Id] = query_ret[Alc.Val]["0"][Alc._Id]["$oid"]
        else
            local doc = {
                [Alc.UserName] = user_name,
                [Alc.Pwd] = pwd,
            }
            local co_ok, insert_account_ret = self.db_client:co_insert_one(1, self.query_db, Alc.Account, doc)
            if not co_ok or 0 ~= insert_account_ret["err_num"] then
                report_error("insert account fail")
                return
            end
            body_tb[Alc._Id] = insert_account_ret[Alc.Inserted_Ids][1]
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
        if 0 ~= insert_token_ret["err_num"] then
            report_error("insert_token fail")
            return
        end
        body_tb[Alc.Token] = token_str
        body_tb[Alc.Timestamp] = timestamp
        rsp_client(from_cnn_id, body_tb)
    end

    local over_fn = function(co_ex)
        -- local custom_data = co:get_custom_data()
        local return_vals = co_ex:get_return_vals()
        if not return_vals then
            body_tb.error = co_ex:get_error_msg()
            rsp_client(from_cnn_id, body_tb)
        end
        Net.close(from_cnn_id)
    end

    local co = ex_coroutine_create(fn, over_fn)
    ex_coroutine_expired(co,20 * 1000)
    ex_coroutine_start(co)
end
