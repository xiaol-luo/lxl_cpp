---@class LoginClient
---@field cnn ClientNetCnn
LoginClient = LoginClient or class("LoginClient")

function LoginClient:ctor(cnn)
    self.cnn = cnn
    self.netid = cnn.netid
    self.state = Login_Client_State.free
    self.user_id = nil
    self.auth_sn = nil
    self.role_id = nil
    self.game_server_key = nil
    self.session_id = nil
end

function LoginClient:send_bin(pid, bin)
    if self.cnn then
        return self.cnn:send_bin(pid, bin)
    end
    return false
end

function LoginClient:send_msg(pid, msg)
    if self.cnn then
        return self.cnn:send_msg(pid, msg)
    end
    return false
end

function LoginClient:disconnect()
    if self.cnn then
        Net.close(self.netid)
    end
    log_print("LoginClient:disconnect ", debug.traceback())
end

function LoginClient:is_authed()
    return self.state > Login_Client_State.authing
end

function LoginClient:is_alive()
    return self.state < Login_Client_State.releasing
end

function LoginClient:is_in_game()
    return Login_Client_State.in_game == self.state
end

function LoginClient:is_free()
    return Login_Client_State.free == self.state
end

function LoginClient:is_authing()
    return Login_Client_State.authing == self.state
end

function LoginClient:is_launching()
    return Login_Client_State.launch_role == self.state
end

