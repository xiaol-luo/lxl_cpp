

World_Role_State_Const = {}
World_Role_State_Const.after_n_secondes_release_all_role = 10
World_Role_State_Const.transfer_role_try_max_times = 3
World_Role_State_Const.transfer_role_try_span_ms = 500
World_Role_State_Const.release_idle_role_after_span_sec = 30
World_Role_State_Const.check_idle_role_span_sec = 5

World_Role_State_Const.check_match_game_role_span_sec = 3
World_Role_State_Const.check_match_game_role_count_per_rpc_query = 30

World_Role_State =
{
    inited = 0,
    launch = 1,
    using = 2,
    idle = 3,
    releasing = 4,
    released = 5,
}


