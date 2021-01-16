
---@class MainRole:DataBase
MainRole = MainRole or class("MainRole", DataBase)

assert(DataBase)

function MainRole:ctor(data_mgr)
    MainRole.super.ctor(self, data_mgr, "main_role")
    ---@type NetMgr
    self._net_mgr = nil
    self._role_id = nil
    self._role_name = nil
end

function MainRole:_on_start()
    MainRole.super._on_start(self)

    self._net_mgr = self.app.net_mgr
    self._event_binder:bind(self.app.data_mgr.game_user, Game_User_Event.role_reachable_change,
            Functional.make_closure(self._on_event_role_reachable_change, self))
    self._event_binder:bind(self.app.net_mgr, Main_Role_Pid.sync_role_data,
            Functional.make_closure(self._on_msg_sync_role_data, self))
end

function MainRole:_on_release()
    MainRole.super._on_release(self)
end

function MainRole:_on_event_role_reachable_change(is_role_reachable)
    if is_role_reachable then
        -- self._role_id = self._role_id
        -- 拉取数据
        self:pull_role_data(0)
    end
end

function MainRole:pull_role_data(pull_type)
    local ret = self._net_mgr.game_gate_net:send_msg(Main_Role_Pid.pull_role_data, { pull_type = pull_type })
    return ret
end

function MainRole:_on_msg_sync_role_data(pto_id, msg)
    log_print("MainRole:_on_msg_sync_role_data", pto_id, msg)
    if 0 == msg.pull_type then
        self._role_id = msg.role_id
        self._role_name = msg.base_info.role_name
    end
    self:fire(Main_Role_Event.sync_role_data, self)
end

function MainRole:get_role_id()
    return self._role_id
end

function MainRole:get_role_name()
    return self._role_name
end