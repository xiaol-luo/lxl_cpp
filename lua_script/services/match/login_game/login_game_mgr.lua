
LoginGameMgr = LoginGameMgr or class("LoginGameMgr", ServiceLogic)

function LoginGameMgr:ctor(logic_mgr, logic_name)
    LoginGameMgr.super.ctor(self, logic_mgr, logic_name)
end

function LoginGameMgr:init()
    LoginGameMgr.super.init(self)
end

function LoginGameMgr:start()
    LoginGameMgr.super.start(self)
end

function LoginGameMgr:stop()
    LoginGameMgr.super.stop(self)
end
