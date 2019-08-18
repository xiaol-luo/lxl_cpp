

function FightMgr:_init_process_rpc_handler()
    self.service.rpc_mgr:set_req_msg_process_fn(FightRpcFn.apply_fight, Functional.make_closure(self._on_rpc_apply_fight, self))
    self.service.rpc_mgr:set_req_msg_process_fn(FightRpcFn.start_fight, Functional.make_closure(self._on_rpc_start_fight, self))
end

function FightMgr:_on_rpc_apply_fight(rpc_rsp, room_id, match_type, match_cells)
    local fight_id = gen_next_seq()
    self._id_to_fight[fight_id] = {
        fight_id = fight_id,
        room_id = room_id,
        start_fight_sec = nil,
        room_client = self.service:create_rpc_client(rpc_rsp.from_host),
    }
    rpc_rsp:respone(Error_None, fight_id, self.service_cfg[Service_Const.Client_Ip], self.service_cfg[Service_Const.Client_Port])
end

function FightMgr:_on_rpc_start_fight(rpc_rsp, fight_battle_id)
    local fight = self._id_to_fight[fight_battle_id]
    if fight then
        rpc_rsp:respone(Error_None)
        fight.start_fight_sec = logic_sec()
    else
        rpc_rsp:respone(Error.Start_Fight.no_fight_battle)
    end
end

