
Cnn_Logic_State = {
    idle = "idle",
    connecting = "connecting",
    connected = "connected",
    error = "error",

}

CnnLogicBase = CnnLogicBase or class("CnnLogicBase")

function CnnLogicBase:ctor()
    self.cnn = nil
    self.ip = ip
    self.port = port
    self.error_num = 0
    self.error_msg = ""
    self.state = Cnn_Logic_State.idle
end

function CnnLogicBase:reset(ip, port)
    self:_release_cnn()
    self.ip = ip
    self.port = port
end

function CnnLogicBase:_release_cnn()
    if self.cnn then
        self.cnn:close()
        self.cnn:release()
        self.cnn = nil
        self.state = Cnn_Logic_State.idle
    end
end

function CnnLogicBase:connect()
    self:_release_cnn()
    self.cnn = GameNet:new(
            Functional.make_closure(self._cb_cnn_open, self),
            Functional.make_closure(self._cb_cnn_close, self),
            Functional.make_closure(self._cb_cnn_recv_msg, self))
    self.cnn:connect(self.ip, self.port)
end

function CnnLogicBase:close()
    if self.cnn then
        self.cnn:close()
    end
end

function CnnLogicBase:release()
    self:_release_cnn()
end


function CnnLogicBase:_cb_cnn_open(is_succ)
    self:on_open(is_succ)
end

function CnnLogicBase:_cb_cnn_close(error_num, error_msg)
    self:on_close(error_num, error_msg)
end

function CnnLogicBase:_cb_cnn_recv_msg(proto_id, bytes, data_len)
    self:on_recv_msg(proto_id, bytes, data_len)
end

function CnnLogicBase:on_open(is_succ)

end

function CnnLogicBase:on_recv_msg(proto_id, bytes, data_len)

end

function CnnLogicBase:on_close(error_num, error_msg)

end



