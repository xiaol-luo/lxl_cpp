---@class FightClient
---@field cnn ClientNetCnn
FightClient = FightClient or class("FightClient")

function FightClient:ctor(cnn)
    self.cnn = cnn
    self.netid = cnn.netid
end

function FightClient:send_bin(pid, bin)
    if self.cnn then
        return self.cnn:send_bin(pid, bin)
    end
    return false
end

function FightClient:send_msg(pid, msg)
    if self.cnn then
        return self.cnn:send_msg(pid, msg)
    end
    return false
end

function FightClient:disconnect()
    if self.cnn then
        Net.close(self.netid)
    end
    -- log_print("FightClient:disconnect ", debug.traceback())
end


