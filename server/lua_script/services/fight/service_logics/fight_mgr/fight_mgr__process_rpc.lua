

function FightMgr:_init_process_rpc_handler()
    self.service.rpc_mgr:set_req_msg_process_fn(FightRpcFn.apply_fight, Functional.make_closure(self._on_rpc_apply_fight, self))
    self.service.rpc_mgr:set_req_msg_process_fn(FightRpcFn.start_fight, Functional.make_closure(self._on_rpc_start_fight, self))
end

function FightMgr:_on_rpc_apply_fight(rpc_rsp, room_id, match_type, match_cells)
    log_debug("FightMgr:_on_rpc_apply_fight match_cells = %s", match_cells)
    local fight_id = gen_next_seq()
    local fight_session_id = gen_next_seq()

    local fight_cls = nil
    if Match_Type.balance == match_type then
        fight_cls = RollPointFight
    end
    local error_num = Error.Apply_Fight.not_match_fight
    if fight_cls then
        room_client = self.service:create_rpc_client(rpc_rsp.from_host)
        fight = fight_cls:new(self, fight_id, fight_session_id, room_id, room_client, match_cells)
        error_num = fight:init()
        if Error_None == error_num then
            self._id_to_fight[fight_id] = fight
        end
    end
    rpc_rsp:response(error_num, fight_id, fight_session_id, self.service.service_cfg[Service_Const.Client_Ip], self.service.service_cfg[Service_Const.Client_Port])
end

function FightMgr:_on_rpc_start_fight(rpc_rsp, fight_battle_id)
    local fight = self._id_to_fight[fight_battle_id]
    if fight then
        fight:on_room_notify_start()
        rpc_rsp:response(Error_None)
    else
        rpc_rsp:response(Error.Start_Fight.no_fight_battle)
    end
end

