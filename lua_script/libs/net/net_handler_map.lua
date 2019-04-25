
NetHandlerMap = NetHandlerMap or class("NetHandlerMap")

function NetHandlerMap:ctor()
    self.native_map = native.make_shared_net_handler_map()
end

function NetHandlerMap:add(net_handler)
    local native_net_handler = net_handler:net_handler_shared_ptr()
    return self.native_map:add(native_net_handler)
end

function NetHandlerMap:remove(netid)
    self.native_map:remove(netid)
end

function NetHandlerMap:clear()
    self.native_map:clear()
end

function NetHandlerMap:get_native_shared_ptr()
    return self.native_map
end

function NetHandlerMap:get_native_weak_ptr()
    return native.to_net_handler_map_weak_ptr(self.native_map)
end