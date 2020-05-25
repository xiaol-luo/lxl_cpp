
ProtoId = {
    ping = 1,
    pong = 2,
    introduce_self = 3,
    for_test = 4,
    for_test_sproto = 5,
    for_test_pb = 6,

    req_login_game = 10000,
    rsp_login_game = 10001,


    req_user_login = 20000,
    rsp_user_login = 20001,
    req_pull_role_digest = 20002,
    rsp_pull_role_digest = 20003,
    req_create_role = 20004,
    rsp_create_role = 20005,
    req_launch_role = 20006,
    rsp_launch_role = 20007,
    req_logout_role = 20008,
    rsp_logout_role = 20009,
    req_reconnect = 20010,
    rsp_reconnect = 20011,

    req_client_forward_game = 20012,

    req_join_match = 20013,
    rsp_join_match = 20014,
    pull_match_state = 20015,
    sync_match_state = 20016,
    req_quit_match = 20017,
    rsp_quit_match = 20018,

    pull_room_state = 20022,
    sync_room_state = 20023,
    notify_bind_room = 20024,
    notify_unbind_room = 20025,
    notify_terminate_room = 20026,

    pull_role_data = 20027,
    sync_role_data = 20028,

    room_service_min_pid = 30000,
    pull_remote_room_state = 30001,
    sync_remote_room_state = 30002,
    room_service_max_pid = 39999,

    fight_service_min_pid = 40000,
    req_bind_fight = 40001,
    rsp_bind_fight = 40002,

    fight_logic_min_pid = 41000, -- 在fight_logic_min_pid与fight_logic_max_pid之间的请求协议都会直接转发给fight:on_client_msg
    pull_fight_state = 41005,
    sync_fight_state = 41006,
    req_fight_opera = 41007,
    rsp_fight_opera = 41008,
    sync_roll_point_result = 41009,
    req_quit_fight = 40010,
    rsp_quit_fight = 40011,
    fight_logic_max_pid = 41999,

    fight_service_max_pid = 49999,
}