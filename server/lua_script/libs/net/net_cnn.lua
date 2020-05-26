
---@class NetCnn: NetHandler
NetCnn = NetCnn or class("NetCnn", NetHandler)

function NetCnn:ctor()
    NetCnn.super.ctor(self)
end

function NetCnn:reset()
    NetCnn.super.reset(self)
end

-- connect类native_handler特有
function NetCnn:cnn_handler_shared_ptr()
    assert(self.native_handler)
    return native.to_connect_handler_shared_ptr(self.native_handler)
end

-- connect类native_handler特有
function NetCnn:cnn_handler_weak_ptr()
    return native.to_connect_handler_weak_ptr(self.native_handler)
end


