
---@class AuthLogic:GameLogicEntity
---@field server AuthServer
AuthLogic = AuthLogic or class("AuthLogic", LogicEntityBase)

function AuthLogic:ctor(logics, logic_name)
    AuthLogic.super.ctor(self, logics, logic_name)
    self._http_net_proxy = nil
    self._db_client = nil
    self._query_db_name = "game_user"
    self._query_coll_name = "game_user"
    self._db_uuid = nil
    self._token_map = {}
end


function AuthLogic:_on_init()
    AuthLogic.super._on_init(self)
    self._http_net_proxy = self.server.http_net:create_proxy()
    local db_setting = self.server.mongo_setting_auth
    self._db_client = MongoClient:new(db_setting.thread_num, db_setting.host, db_setting.auth_db,  db_setting.user, db_setting.pwd)
    self._db_uuid = self.server.db_uuid
end

function AuthLogic:_on_start()
    AuthLogic.super._on_start(self)
    self._http_net_proxy:set_handle_fn(Auth_Http_Method.login_game, Functional.make_closure(self._on_http_login_game, self))
    self._http_net_proxy:set_handle_fn(Auth_Http_Method.verity_token, Functional.make_closure(self._on_http_verity_token, self))
    self._db_client:start()
end

function AuthLogic:_on_stop()
    AuthLogic.super._on_stop(self)
    self._db_client:stop()
    self._http_net_proxy:clear_all()
end

function AuthLogic:_on_release()
    AuthLogic.super._on_release(self)
end


---@param from_cnn_id number
---@param method HttpMethod
---@param req_url string
---@param heads_map table<string, string>
---@param body string
function AuthLogic:_on_http_login_game(from_cnn_id, method, req_url, heads_map, body)
    local platform_name = heads_map["platform_name"]
    local platform_token = heads_map["platform_token"]
    local platform_token_timestamp = heads_map["platform_token_timestamp"]
    local platform_account_id = heads_map["platform_account_id"]
    local app_id = heads_map["app_id"]

    if not platform_name
            or not platform_token
            or not platform_token_timestamp
            or not platform_account_id
            or not app_id
    then
        self:_http_rsp_help(from_cnn_id, {
            error_num = 1,
            error_msg = string.format("input params invalid : %s", lua_json.encode(heads_map)),
        })
        Net.close(from_cnn_id)
        return
    end

    local rsp_body = {}
    rsp_body.error_num = 0
    rsp_body.error_msg = nil
    rsp_body.user_id = nil
    rsp_body.user_token = nil
    rsp_body.user_token_timestamp = nil

    local reply_client_with_error = function (error_num, error_msg)
        rsp_body.error_num = error_num
        rsp_body.error_msg = error_msg
        self:_http_rsp_help(from_cnn_id, rsp_body)
    end

    ---@param co_ex CoroutineEx
    local over_logic = function(co_ex)
        local return_vals = co_ex:get_return_vals()
        if not return_vals then
            reply_client_with_error(10, co_ex:get_error_msg() or "unknown error")
        end
        Net.close(from_cnn_id)
    end

    local main_logic = function()
        local co_ex = ex_coroutine_running()
        local query_params = {}
        table.insert(query_params, string.format("%s=%s", "token", platform_token))
        table.insert(query_params, string.format("%s=%s", "timestamp", platform_token_timestamp))
        local platform_http_ip = self.server.init_setting.platform_http_ip
        local platform_http_port = self.server.init_setting.platform_http_port
        local query_url = string.format("%s:%s%s?%s", platform_http_ip, platform_http_port, "/verity_token", table.concat(query_params, "&"))
        local co_ok, tmp_ret = HttpClient.co_get(query_url, {})
        if not co_ok then
            ---@type HttpClientEventResult
            local http_event_ret = tmp_ret
            local error_msg = string.format("query_platform f fail, reason is %s:%s", http_event_ret.event_type, http_event_ret.error_num)
            reply_client_with_error(20, error_msg)
            return
        end
        ---@type HttpClientRspResult
        local http_rsp_ret = tmp_ret
        if "ok" ~= http_rsp_ret.state then
            local error_msg = string.format("query_platform fail, http response state is %s", http_rsp_ret.state)
            reply_client_with_error(30, error_msg)
            return
        end
        local http_body = lua_json.decode(http_rsp_ret.body)
        if Error_None ~= http_body.error_num then
            local error_msg = string.format("query_platform fail, http response body with  error:%s, %s",
                    http_body.error_num, http_body.error_msg or "")
            reply_client_with_error(40, error_msg)
            return
        end
        if platform_account_id ~= http_body.platform_account_id or app_id ~= http_body.app_id then
            local error_msg = string.format("platform_account_id[%s:%s] or app_id[%s:%s] mismatch",
                    platform_account_id, http_body.platform_account_id,
                    app_id, http_body.app_id)
            reply_client_with_error(50, error_msg)
            return
        end
        local db_ret = nil
        co_ok, db_ret = self._db_client:co_find_one(math.random(1, 999), self._query_db_name, self._query_coll_name, {
            platform_name = platform_name,
            account_id = platform_account_id,
        })
        if not co_ok then
            reply_client_with_error(60, "find user with platform infomation fail")
            return
        end
        if Error_None ~= db_ret.error_num then
            reply_client_with_error(70, "find user with platform infomation fail")
            return
        end

        local user_id = nil
        if db_ret.matched_count > 0 then
            user_id = db_ret.val["0"].user_id
            if not user_id then
                reply_client_with_error(81, "unknown error")
                return
            end
        else
            user_id = self._db_uuid:apply(DB_Uuid_Names.user_id)
            if not user_id then
                reply_client_with_error(80, "apply user id from db uuid fail")
                return
            end
            co_ok, db_ret = self._db_client:co_insert_one(user_id, self._query_db_name, self._query_coll_name, {
                user_id = user_id,
                platform_name = platform_name,
                account_id = platform_account_id,
            })
            if not co_ok then
                reply_client_with_error(80, "create user fail ")
                return
            end
            if Error_None ~= db_ret.error_num or db_ret.inserted_count <= 0 then
                reply_client_with_error(90, "create user fail 2 ")
                return
            end
        end
        rsp_body.user_id = user_id
        rsp_body.user_token = gen_uuid()
        rsp_body.user_token_timestamp = tostring(os.time())

        self._token_map[rsp_body.user_token] = {
            timestamp = rsp_body.user_token_timestamp,
            user_id = rsp_body.user_id,
            app_id = app_id,
            platform_name = platform_name,
            platform_account_id = platform_account_id,
            platform_token = platform_token,
            platform_token_timestamp = platform_token_timestamp,
        }
        self:_http_rsp_help(from_cnn_id, rsp_body)
    end

    local co = ex_coroutine_create(main_logic, over_logic)
    ex_coroutine_expired(co, 30 * 1000)
    ex_coroutine_start(co)
end

---@param from_cnn_id number
---@param method HttpMethod
---@param req_url string
---@param heads_map table<string, string>
---@param body string
function AuthLogic:_on_http_verity_token(from_cnn_id, method, req_url, heads_map, body)
    local token_str = heads_map["token"]
    local timestamp_str = heads_map["timestamp"]

    if not token_str or not timestamp_str then
        self:_http_rsp_help(from_cnn_id, {
            error_num = 1,
            error_msg = "token or timestamp_str is not valid",
        })
    else
        local token_item = self._token_map[token_str]
        if not token_item or token_item.timestamp ~= timestamp_str then
            self:_http_rsp_help(from_cnn_id, {
                error_num = 1,
                error_msg = "token_str and timestamp_str is mismatch",
            })
        else
            self:_http_rsp_help(from_cnn_id, {
                error_num = 0,
                error_msg = nil,
                user_id = token_item.user_id,
                app_id = token_item.app_id,
            })
        end
    end
end


function AuthLogic:_http_rsp_help(cnn_id, body)
    local body_str = body
    if is_table(body) then
        body_str = lua_json.encode(body)
    end
    Net.send(cnn_id, gen_http_rsp_content(200, "OK", body_str))
    Net.close(cnn_id)
end
