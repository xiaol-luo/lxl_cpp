
function PlatformService:_init_http_net()
    self.http_svr = HttpNetModule:new(self.module_mgr, "http_svr")
    self.module_mgr:add_module(self.http_svr)
    local http_setting = SERVICE_SETTING["http"]
    self.http_svr:init(http_setting["listen_port"], self:get_http_handle_fns())
end

function PlatformService:get_http_handle_fns()
    local ret = {}
    local acl = AccountLogic:new(self)
    for k, v in pairs(acl:get_http_handle_fns()) do
        assert(not ret[k], string.format("dumplicate key %s", k))
        ret[k] = v
    end
    return ret
end