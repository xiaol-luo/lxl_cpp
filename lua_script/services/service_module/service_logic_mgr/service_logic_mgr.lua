
ServiceLogicMgr = ServiceLogicMgr or class("ServiceLogicMgr", ServiceModule)

function ServiceLogicMgr:ctor(module_mgr, module_name)
    ServiceLogicMgr.super.ctor(self, module_mgr, module_name)
    self.service = self.module_mgr.service
    self.logics = {}
end

function ServiceLogicMgr:init()
    ServiceLogicMgr.super.init(self)
    for _, v in ipairs(self.logics) do
        local logic_name = v:get_logic_name()
        assert(not self.module_mgr.service[logic_name])
        self.module_mgr.service[logic_name] = v
    end
    for _, v in ipairs(self.logics) do
        v:init()
    end
end

function ServiceLogicMgr:add_logic(logic)
    table.insert(self.logics, logic)
end

function ServiceLogicMgr:start()
    ServiceLogicMgr.super.start(self)
    for _, v in ipairs(self.logics) do
        v:start()
    end
end

function ServiceLogicMgr:stop()
    ServiceLogicMgr.super.stop(self)
    for _, v in ipairs(self.logics) do
        v:stop()
    end
end

function ServiceLogicMgr:release()
    ServiceLogicMgr.super.release(self)
    for _, v in ipairs(self.logics) do
        v:release()
    end
    for _, v in ipairs(self.logics) do
        local logic_name = v:get_logic_name()
        self.module_mgr.service[logic_name] = nil
    end
    self.logics = {}
end

