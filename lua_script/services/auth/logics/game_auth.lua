
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
    Err_Num = "err_num",
    Matched_Count = "matched_count",
    Content = "content",
    Uid = "uid",
}

local Gac = GameAuth_Const

function GameAuth:ctor(service_main)
    self.service_main = service_main
    self.timer_proxy = TimerProxy:new()
end

function GameAuth:get_http_handle_fns()
    local ret = {}
    ret["/index"] = Functional.make_closure(GameAuth.index, self)
    return ret
end

function GameAuth:index(from_cnn_id, method, req_url, kv_params, body)
    local rsp_content = gen_http_rsp_content(200, "OK", "", {})
    Net.send(from_cnn_id, rsp_content)
    Net.close(from_cnn_id)
end
