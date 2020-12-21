---@class FightNetBase:EventMgr
FightNetBase = class("FightNetBase", EventMgr)

function FightNetBase:ctor(net_mgr)
    FightNetBase.super.ctor(self)
    ---@type NetMgr
    self._net_mgr = net_mgr
    ---@type LuaApp
    self._app = self._net_mgr.app
    ---@type ProtoParser
    self._pto_parser = self._net_mgr._pto_parser
end

function FightNetBase:init()
    self:_on_init()
end

function FightNetBase:release()
    self:_on_release()
    self:cancel_all()
end

function FightNetBase:_on_init()

end

function FightNetBase:_on_release()

end

function FightNetBase:connect()

end

function FightNetBase:disconnect()

end

function FightNetBase:reconnect()
    self:disconnect()
    self:connect()
end

function FightNetBase:get_host()

end

function FightNetBase:get_error_msg()

end

function FightNetBase:is_ready()

end

function FightNetBase:is_connecting()

end

function FightNetBase:notify_connect_done()
    self._net_mgr:fire(Game_Net_Event.fight_connect_done, self:is_ready(), self:get_error_msg())
end

function FightNetBase:notify_connect_start()
    self._net_mgr:fire(Game_Net_Event.fight_connect_start)
end

function FightNetBase:notify_ready_state()
    self._net_mgr:fire(Game_Net_Event.fight_connect_ready_change, self:is_ready())
end

function FightNetBase:send_msg(pid, msg)

end




