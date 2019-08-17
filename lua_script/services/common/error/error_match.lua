
Error.Join_Match = {
    role_match_state_not_fit = 1,
    no_valid_match_service = 2,
    invalid_match_type = 3,
    match_leader_role_id_nil = 4,
    match_role_already_in_match = 5,
    match_cell_not_exist = 6,
    join_match_role_count_illegal = 7,
    is_matching = 8,
    remote_is_matching = 9,
}

Error.Quit_Match = {
    match_cell_not_exist = 1,
    role_has_no_right_to_quit = 2,
    not_matching = 3,
    waiting_enter_room = 4,
    match_finished = 5,
    need_try_again = 6,
}

Error.Bind_Room = {
    no_exist_room = 1,
    no_exist_role = 2,
    session_id_not_equal = 3,
}

Error.Start_Fight = {
    no_fight_battle = 1,
}