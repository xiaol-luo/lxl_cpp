
---@class FightMgr:GameLogicEntity
---@field logics FightLogicService
FightMgr = FightMgr or class("FightMgr", GameLogicEntity)

function FightMgr:_on_init()
    FightMgr.super._on_init(self)
    ---@type MatchServiceMgr
    self.server = self.server
    ---@type table<string, FightBase>
    self._key_to_fight = {}
    ---@type table<string, FightBase>
    self._room_key_to_fight = {}

    ---@type table<number, FightRole>
    self._netid_to_role = {}

    self._over_fights = {}

    self._msg_handler_tb = {}
    self._msg_handler_tb[Fight_Pid.req_bind_fight] = Functional.make_closure(self._on_msg_req_bind_fight, self)
    self._msg_handler_tb[Fight_Pid.pull_fight_state] = Functional.make_closure(self._on_msg_pull_fight_state, self)
    self._msg_handler_tb[Fight_Pid.req_fight_opera] = Functional.make_closure(self._on_msg_req_fight_opera, self)
end

function FightMgr:_on_start()
    FightMgr.super._on_start(self)

    for k, v in pairs(self._msg_handler_tb) do
        self.logics.client_mgr:set_msg_handler(k, v)
    end

    self._event_binder:bind(self.logics.client_mgr, Fight_Client_Event.fight_client_disconnect,
            Functional.make_closure(self._on_event_fight_client_disconnect, self))
end

function FightMgr:_on_stop()
    FightMgr.super._on_stop(self)
    self._rpc_svc_proxy:clear_remote_call()

    for k, _ in pairs(self._msg_handler_tb) do
        self.logics.client_mgr:set_msg_handler(k, nil)
    end
end

function FightMgr:_on_release()
    FightMgr.super._on_release(self)
end

function FightMgr:_on_update()
    FightMgr.super._on_update(self)
    for k, v in pairs(self._key_to_fight) do
        v:update()
        if v:is_over() then
            table.insert(self._over_fights, k)
        end
    end
    if next(self._over_fights) then
        -- log_print("FightMgr:_on_update 1", self._over_fights)
        for _, v in ipairs(self._over_fights) do
            self:remove_fight(v)
        end
        self._over_fights = {}
    end
end

--- rpc函数

function FightMgr:_on_map_remote_call_handle_fns()
    self._method_name_to_remote_call_handle_fns[Rpc.fight.setup_fight] = Functional.make_closure(self._on_rpc_setup_fight, self)
end

---@param rpc_rsp RpcRsp
function FightMgr:_on_rpc_setup_fight(rpc_rsp, room_key, room_msg)
    local error_num = Error.setup_fight.no_fit_theme
    local msg = {}
    room_msg.room_server_key = rpc_rsp.from_host
    room_msg.room_key = room_key
    if not self:get_fight_by_room_key(room_key) then
        if Match_Theme.two_dice == room_msg.match_theme then
            local fight = TwoDiceFight:new(self, room_msg)
            fight:init()
            self._key_to_fight[fight.fight_key] = fight
            self._room_key_to_fight[room_key] = fight
            fight:start()
            error_num = Error_None
            msg = {
                fight_key = fight.fight_key,
                token = fight.token,
                ip = self.logics.server.init_setting.advertise_client_ip,
                port = self.logics.server.init_setting.advertise_client_port,
            }
        end
    end
    rpc_rsp:response(error_num, msg)
end

function FightMgr:get_fight(fight_key)
    local ret = self._key_to_fight[fight_key]
    return ret
end

function FightMgr:get_fight_by_room_key(room_key)
    local ret = self._room_key_to_fight[room_key]
    return room
end

function FightMgr:remove_fight(fight_key)
    local fight = self:get_fight(fight_key)
    if fight then
        fight:stop()
        fight:release()
        self._key_to_fight[fight_key] = nil
        self._room_key_to_fight[fight.room_key] = nil

    end
end

---@param client FightClient
function FightMgr:_on_msg_req_bind_fight(client, pid, msg)
    log_print("FightMgr:_on_msg_req_bind_fight ", pid, msg)
    local error_num = Error_None
    repeat
        local fight = self:get_fight(msg.fight_key)
        if not fight then
           error_num = Error.bind_fight.not_find_fight
            break
        end
        local fight_role = self:get_fight_role(client.netid)
        if fight_role then
            break
        end
        fight_role = FightRole:new()
        fight_role.netid = client.netid
        fight_role.role_id = msg.role_id
        fight_role.wt.client = client
        fight_role.wt.fight = fight
        error_num = fight:bind_role(fight_role)
        if Error_None ~= error_num then
            break
        end
        self._netid_to_role[fight_role.netid] = fight_role
    until true
    client:send_msg(Fight_Pid.rsp_bind_fight, {
        error_num = error_num
    })
end

function FightMgr:remove_fight_role(netid)
    ---@type FightRole
    local fight_role = self._netid_to_role[netid]
    self._netid_to_role[netid] = nil
    if fight_role then
        ---@type FightClient
        local client = fight_role.wt.client
        if client then
            client:disconnect()
        end
    end
end

---@return FightRole
function FightMgr:get_fight_role(netid)
    local ret = self._netid_to_role[netid]
    return ret
end

function FightMgr:_on_msg_pull_fight_state(client, pid, msg)
    local fight_role = self:get_fight_role(client.netid)
    if fight_role and fight_role.wt.fight then
        fight_role.wt.fight:sync_fight_state(client)
    end
end

function FightMgr:_on_msg_req_fight_opera(client, pid, msg)
    local error_num = Error_None
    repeat
        local fight_role = self:get_fight_role(client.netid)
        if not fight_role then
            error_num = Error.opera_fight.not_find_role
            break
        end
        if not fight_role.wt.fight then
            error_num = Error.opera_fight.not_find_fight
            break
        end
        ---@type FightBase
        local fight = fight_role.wt.fight
        error_num = fight:handle_role_opera(fight_role)
    until true
    client:send_msg(Fight_Pid.rsp_fight_opera, {
        unique_id = msg.unique_id,
        error_num = error_num,
    })
end

---@param fight_client FightClient
function FightMgr:_on_event_fight_client_disconnect(netid)
    local fight_role = self:get_fight_role(netid)
    if fight_role then
        if fight_role.wt.fight then
            fight_role.wt.fight:offline_role(fight_role.role_id, fight_role.netid)
        end
    end
    -- self._netid_to_role[netid] = nil
    self:remove_fight_role(netid)
end


