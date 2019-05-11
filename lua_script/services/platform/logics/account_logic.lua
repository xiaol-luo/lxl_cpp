
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

    if not user_name or #user_name <= 0 or not appid or #appid < 0 then
        body_tb.error = "invalid user name or appid"
        rsp_client(from_cnn_id, body_tb)
        return
    end

    local body_tb = {}
    body_tb.error = ""
    body_tb[Alc.Appid] = appid
    body_tb[Alc.UserName] = user_name
    body_tb[Alc._Id] = nil
    body_tb[Alc.Token] = nil
    body_tb[Alc.Timestamp] = nil

    -- TODO: 由于协程不能杀掉，所以感觉应该在携程上包一层，给它加上一些特性，比如Cancel自己
    local share_info = {
        fn_error = nil,
        is_timeout = false,
        timer_id = nil,
    }

    local cancel_timer = function()
        if share_info.timer_id then
            self.timer_proxy:remove(share_info.timer_id)
            share_info.timer_id = nil
        end
    end
    local report_error = function(error_msg)
        cancel_timer()
        body_tb.error = error_msg or "unknown"
        rsp_client(from_cnn_id, body_tb)
    end

    local fn = function()
        local filter = { [Alc.UserName]= user_name }
        local opt = MongoOptFind:new()
        opt:set_max_time(10 * 1000)
        opt:set_projection({ [Alc.UserName]=true, [Alc.Pwd]=true })
        local query_ret = self.db_client:co_find_one(1, self.query_db, Alc.Account, filter, opt)
        if 0 ~= query_ret["err_num"] then
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
            local insert_account_ret = self.db_client:co_insert_one(1, self.query_db, Alc.Account, doc)
            if 0 ~= insert_account_ret["err_num"] then
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
        local insert_token_ret = self.db_client:co_insert_one(1, self.query_db, Alc.Token, doc)
        if 0 ~= insert_token_ret["err_num"] then
            report_error("insert_token fail")
            return
        end
        body_tb[Alc.Token] = token_str
        body_tb[Alc.Timestamp] = timestamp
        rsp_client(from_cnn_id, body_tb)
        cancel_timer()
    end

    local co = coroutine.create(fn)
    share_info.timer_id = self.timer_proxy:delay(function ()
        self.timer_proxy:remove(share_info.timer_id)
        share_info.timer_id = nil
        share_info.is_timeout = true
        body_tb.error = share_info.fn_error or "unknown"
        if "dead" ~= coroutine.status(co) then
            if not error_msg then
                body_tb.error = "timeout"
            end
        end
        rsp_client(from_cnn_id, body_tb)
    end, 20 * 1000)
    coroutine_resume(co)
end
