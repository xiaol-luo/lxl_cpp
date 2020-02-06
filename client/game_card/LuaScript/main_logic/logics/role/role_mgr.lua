
RoleMgr = RoleMgr or class("RoleMgr")

function RoleMgr:ctor(main_logic)
    self.main_logic = main_logic
    self.event_subscriber = self.main_logic.event_mgr:create_subscriber()
    self._roles = {}
    self.main_role = nil
end

function RoleMgr:init()
    self.event_subscriber:subscribe(ProtoId.sync_role_data, Functional.make_closure(self._on_msg_sync_role_data, self))
end

function RoleMgr:add_role(role)
    self._roles[role.role_id] = role
end

function RoleMgr:remove_role(role_id)
    self._roles[role_id] = nil
end

function RoleMgr:get_role(role_id)
    return self._roles[role_id]
end

function RoleMgr:_on_msg_sync_role_data(proto_id, msg)
    log_debug("RoleMgr:_on_msg_sync_role_data %s  xx %s", proto_id, msg)
end





