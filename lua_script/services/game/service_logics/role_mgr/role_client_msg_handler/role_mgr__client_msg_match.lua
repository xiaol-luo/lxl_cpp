
function RoleMgr:_setup_client_mgs_process_fn__match()
    -- for test
    self.service.net_forward:set_client_msg_process_fn(ProtoId.req_pull_role_digest, function(role, pid, msg)
        role:send_to_client(pid, msg)
    end)
end