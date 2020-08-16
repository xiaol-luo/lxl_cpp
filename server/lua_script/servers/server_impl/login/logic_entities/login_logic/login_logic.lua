
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

    self._msg_handle_fns[Login_Pid.req_login_game] = Functional.make_closure(self._on_msg_req_login_game, self)
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
    ---- todo: 定义错误码
    --if login_Client_State.free ~= login_client.state or login_client.user_id then
    --    login_client:send_msg(Login_Pid.rsp_user_login, { error_num = 1})
    --    login_client:disconnect()
    --    return
    --end
    --if not self.server.discovery:is_cluster_can_work() then
    --    login_client:send_msg(Login_Pid.rsp_user_login, { error_num = 2})
    --    login_client:disconnect()
    --end
    --login_client.user_id = msg.user_id
    --login_client.auth_sn = msg.auth_sn
    --login_client.state = login_Client_State.manage_role
    login_client:send_msg(Login_Pid.rsp_login_game, { error_num = Error_None })
end


