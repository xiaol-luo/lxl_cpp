
Error.Login_Game = {
    not_login_item = 1,
    start_coro_fail = 2,
    auth_login_fail = 3,
    coro_raise_error = 4,
    query_db_error = 5,
    no_gate_available = 6,
    apply_user_id_fail = 7,
}

Error.Gate_User_Login = {
    no_client = 1,
    state_not_fit = 2,
    start_coro_fail = 3,
    auth_fail = 4,
    coro_raise_error = 5,
}

Error.Reconnect_Game = {
    auth_user_fail = 1,
    gate_client_state_not_fit = 2,
    gate_no_client = 3,
    no_valid_world_service = 4,
    bind_role_fail = 5,
    world_no_role = 6,
    token_not_fit = 7,
    role_not_idle = 8,
    game_change_client = 9,
}

Error.Pull_Role_Digest = {
    no_client = 1,
    need_auth = 2,
    no_valid_world_service = 3,
    query_fail = 4,
}

Error.Create_Role = {
    no_client = 1,
    need_auth = 2,
    no_valid_world_service = 3,
    query_fail = 4,
}

Error.Launch_Role = {
    no_valid_world_service = 1,
    state_not_fit = 2,
    no_valid_game_service = 3,
    role_releasing = 4,
    repeat_launch = 5,
    another_launch = 6,
    launch_fail = 7,
    loading_from_db = 8,
    game_role_state_in_error = 9,
    query_db_fail = 10,
    game_change_client = 11,

}

Error.Logout_Role = {
    not_match_role = 1,
    not_launch_role = 2,
    state_not_fit = 3,

}

