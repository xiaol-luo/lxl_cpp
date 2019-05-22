
ServiceLogicMgr = ServiceLogicMgr or class("ServiceLogicMgr", ServiceModule)

function ServiceLogicMgr:ctor(module_mgr, module_name)
    ServiceLogicMgr.super.ctor(self, module_mgr, module_name)
    self.http_service = nil
    self.listen_port = nil
end

function ServiceLogicMgr:init()
    ServiceLogicMgr.super.init(self)
end

function ServiceLogicMgr:start()
    self.curr_state = ServiceModuleState.Started
end

function ServiceLogicMgr:stop()
    self.curr_state = ServiceModuleState.Stopped
end