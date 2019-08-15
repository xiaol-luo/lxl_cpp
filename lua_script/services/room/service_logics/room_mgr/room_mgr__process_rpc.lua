

function RoomMgr:_init_process_rpc_handler()
    self.service.rpc_mgr:set_req_msg_process_fn(RoomRpcFn.apply_room, Functional.make_closure(self._on_rpc_apply_room, self))
end

function RoomMgr:_on_rpc_apply_room(rpc_rsp, match_type, match_cells)
    rpc_rsp:respone(Error_None, gen_next_seq())
end

