
CnnHandlerMap = CnnHandlerMap or class("CnnHandlerMap")

function CnnHandlerMap:ctor()
    self.native_map = native.make_shared_cnn_handler_map()
end

function CnnHandlerMap:add(net_handler)
    local native_net_handler = net_handler:net_handler_shared_ptr()
    return self.native_map:add(native_net_handler)
end

function CnnHandlerMap:remove(netid)
    self.native_map:remove(netid)
end

function CnnHandlerMap:clear()
    self.native_map:clear()
end

function CnnHandlerMap:size()
    return self.native_map:size()
end

function CnnHandlerMap:get_native_shared_ptr()
    return self.native_map
end

function CnnHandlerMap:get_native_weak_ptr()
    return native.to_cnn_handler_map_weak_ptr(self.native_map)
end