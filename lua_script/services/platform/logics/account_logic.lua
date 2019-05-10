
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
    body_tb.content = {}

    if not user_name or #user_name <= 0 or not appid or #appid < 0 then
        body_tb.error = "invalid user name or appid"
        rsp_client(from_cnn_id, body_tb)
        return
    end

    local filter = { [Alc.UserName]= user_name }
    local opt = MongoOptFind:new()
    opt:set_max_time(10 * 1000)
    opt:set_projection({ [Alc.UserName]=true, [Alc.Pwd]=true })
    self.db_client:find_one(1, self.query_db, Alc.Account, filter,
            Functional.make_closure(AccountLogic._login_query_cb, self, from_cnn_id, appid, user_name, pwd), opt)
end

function AccountLogic:_save_token(from_cnn_id, token, appid, user_name, timestamp)
    local doc = {
        [Alc.Appid] = appid,
        [Alc.UserName] = user_name,
        [Alc.Timestamp] = timestamp,
    }
    self.db_client:insert_one(1, self.query_db, Alc.Token, doc)
end

function AccountLogic:_login_query_cb(from_cnn_id, appid, user_name, pwd, result)
    -- log_debug("AccountLogic:_login_query_cb %s", result)
    local body_tb = {}
    body_tb.error = ""
    body_tb.content = {}
    body_tb[Alc.UserName] = user_name
    body_tb[Alc.Appid] = appid
    if 0 ~= result["err_num"] then
        body_tb.error = result["err_num"]
        rsp_client(from_cnn_id, body_tb)
        return
    end
    if result["matched_count"] > 0 then
        body_tb.content = result[Alc.Val]
        body_tb[Alc._Id] = result[Alc.Val]["0"][Alc._Id]["$oid"]
        body_tb[Alc.Token] = native.gen_uuid()
        body_tb[Alc.Timestamp] = os.time()
        rsp_client(from_cnn_id, body_tb)
        self:_save_token(from_cnn_id, appid, user_name, body_tb[Alc.Timestamp])
        return
    end

    local doc = {
        [Alc.UserName] = user_name,
        [Alc.Pwd] = pwd,
    }
    self.db_client:insert_one(1, self.query_db, Alc.Account, doc,
            Functional.make_closure(AccountLogic._login_insert_cb, self, from_cnn_id, appid, user_name, pwd))
end

function AccountLogic:_login_insert_cb(from_cnn_id,appid, user_name, pwd, result)
    -- log_debug("AccountLogic:_login_insert_cb %s", result)
    local body_tb = {}
    body_tb.error = ""
    body_tb.content = {}
    body_tb[Alc.Appid] = appid
    body_tb[Alc.UserName] = user_name
    if 0 ~= result["err_num"] then
        body_tb.error = result["err_num"]
    end
    if result["inserted_count"] > 0 then
        body_tb.content = result[Alc.Val]
        body_tb[Alc._Id] = result[Alc.Inserted_Ids][1]
        body_tb[Alc.Token] = native.gen_uuid()
        body_tb[Alc.Timestamp] = os.time()
    end
    rsp_client(from_cnn_id, body_tb)
    self:_save_token(from_cnn_id, appid, user_name, body_tb[Alc.Timestamp])
end