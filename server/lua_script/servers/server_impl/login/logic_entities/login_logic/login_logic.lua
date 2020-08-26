
---@class LoginLogic:GameLogicEntity
LoginLogic = LoginLogic or class("LoginLogic", LogicEntityBase)

function LoginLogic:ctor(logics, logic_name)
    LoginLogic.super.ctor(self, logics, logic_name)
    ---@type LoginClientMgr
    self._client_mgr = nil
    self._msg_handle_fns = {}
end


function LoginLogic:_on_init()
    LoginLogic.super._on_init(self)
    self._client_mgr = self.logics.client_mgr

    self._msg_handle_fns[Login_Pid.req_login_user] = Functional.make_closure(self._on_msg_req_login_game, self)
end

function LoginLogic:_setup_msg_handler(is_setup)
    for pid, _ in pairs(self._msg_handle_fns) do
        self._client_mgr:set_msg_handler(pid, nil)
    end
    if is_setup then
        for pid, fn in pairs(self._msg_handle_fns) do
            self._client_mgr:set_msg_handler(pid, fn)
        end
    end
end

function LoginLogic:_on_start()
    LoginLogic.super._on_start(self)
    self:_setup_msg_handler(true)
end

function LoginLogic:_on_stop()
    LoginLogic.super._on_stop(self)
    self:_setup_msg_handler(false)
end

function LoginLogic:_on_release()
    LoginLogic.super._on_release(self)
end

---@param login_client loginClient
function LoginLogic:_on_msg_req_login_game(login_client, pid, msg)
    local kv_tb = {}
    kv_tb["platform_name"] = msg.platform
    kv_tb["platform_token"] = msg.token
    kv_tb["platform_token_timestamp"] = msg.timestamp
    kv_tb["platform_account_id"] = msg.account_id
    kv_tb["app_id"] = msg.app_id
    kv_tb["platform_token"] = msg.token
    local params_tb = {}
    for  k, v in pairs(kv_tb) do
        table.insert(params_tb, string.format("%s=%s", k, v))
    end
    local Auth_Ip = "127.0.0.1"
    local Auth_Port = 32002
    local query_url = string.format("http://%s:%s/login_game?%s", Auth_Ip, Auth_Port, table.concat(params_tb, "&"))
    HttpClient.get(query_url, function(http_ret)
        -- log_print("LoginLogic:_on_msg_req_login_game", http_ret)
        local error_num = Error_None
        if "OK" == http_ret.state then
            local rsp_data = lua_json.decode(http_ret.body)
            if Error_None == rsp_data.error_num then
                login_client:send_msg(Login_Pid.rsp_login_user, {
                    error_num = Error_None,
                    token = rsp_data.user_token,
                    timestamp = tostring(rsp_data.user_token_timestamp),
                    user_id = rsp_data.user_id,
                    auth_ip = Auth_Ip,
                    auth_port = Auth_Port,
                })
            else
                error_num = rsp_data.error_num
            end
        else
            error_num = 1
        end

        if Error_None ~= error_num then
            login_client:send_msg(Login_Pid.rsp_login_user, { error_num = error_num})
        end
    end)
end


