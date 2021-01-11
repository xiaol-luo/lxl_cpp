
---@class FightBase
FightBase = FightBase or class("FightBase")

function FightBase:ctor(fight_mgr, setup_data)
    ---@type FightMgr
    self._fight_mgr = fight_mgr
    self.setup_data = setup_data

    self.fight_key = nil
    self.token = nil
    self.room_server_key = nil
    self.room_key = nil

    ---@type EventBinder
    self._event_binder = EventBinder:new()
    ---@type TimerProxy
    self._timer_proxy = TimerProxy:new()
    ---@type RpcServiceProxy
    self._rpc_svc_proxy = self._fight_mgr.server.rpc:create_svc_proxy()
    ---@type table<number, FightRole>
    self._id_to_role = {}
end

function FightBase:init()
    self.fight_key = gen_uuid()
    self.token = gen_uuid()
    self.room_key = self.setup_data.room_key
    self.room_server_key = self.setup_data.room_server_key
    self:_on_init()
end

function FightBase:start()
    self:_on_start()
end

function FightBase:stop()
    self:_on_stop()
end

function FightBase:release()
    self._event_binder:release_all()
    self._timer_proxy:release_all()
    self:_on_release()
    for k, v in pairs(self._id_to_role) do
        ---@type FightClient
        local client = v.wt.client
        if client then
            client:disconnect()
        end
    end
end

function FightBase:update()
    self:_on_update()
end

---@param fight_client FightClient
function FightBase:sync_fight_state(fight_client)
    if fight_client then
        local msg_id, msg = self:_collect_fight_state_data()
        fight_client:send_msg(msg_id, msg)
    end
end

---@param fight_role FightRole
function FightBase:bind_role(fight_role)
    -- 简单处理，后边加校验
    local old_fight_role = self._id_to_role[fight_role.role_id]
    self._id_to_role[fight_role.role_id] = fight_role
    self:_on_bind_role(fight_role, old_fight_role)
    return Error_None
end

function FightBase:offline_role(role_id, netid)
    self:_on_offline_role(role_id, netid)
end

---@param fight_role FightRole
function FightBase:handle_role_opera(fight_role, msg)
    local now_fight_role = self._id_to_role[fight_role.role_id]
    if now_fight_role.netid ~= fight_role.netid then
        return Error.fight.netid_mismatch
    end
    local ret = self:_on_opera(fight_role, msg)
    return ret
end

function FightBase:is_over()
    -- override by subclass
    return true
end

function FightBase:_on_init()
    -- override by subclass
end

function FightBase:_on_start()
    -- override by subclass
end

function FightBase:_on_stop()
    -- override by subclass
end

function FightBase:_on_release()
    -- override by subclass
end

function FightBase:_on_update()
    -- override by subclass
end

function FightBase:_on_opera(fight_role, msg)
    -- override by subclass
    return Error_None
end

function FightBase:_on_bind_role(new_fight_role, old_fight_role)
    -- override by subclass
end

function FightBase:_on_offline_role(role_id, netid)
    -- override by subclass
end

function FightBase:_collect_fight_state_data()
    -- override by subclass
    -- return msg_id, msg
end



