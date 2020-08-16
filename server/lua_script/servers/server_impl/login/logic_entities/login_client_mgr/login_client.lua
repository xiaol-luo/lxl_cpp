---@class loginClient
---@field cnn ClientNetCnn
LoginClient = LoginClient or class("LoginClient")

function LoginClient:ctor(cnn)
    self.cnn = cnn
    self.netid = cnn.netid
    self.extra_data = {}
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
    self.extra_data = {}
end


