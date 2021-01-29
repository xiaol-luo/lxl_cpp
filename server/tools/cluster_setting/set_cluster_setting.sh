#!/bin/bash

# etcdctl --endpoints=http://127.0.0.1:8100,http://127.0.0.1:8200,http://127.0.0.1:8300 ls -r /

endpoints_flag="--endpoints=http://127.0.0.1:8100,http://127.0.0.1:8200,http://127.0.0.1:8300"
zone_name="zone_0"
zone_setting_path="/${zone_name}/zone_setting"

etcdctl ${endpoints_flag} set ${zone_setting_path}/is_ready 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/role_min_nums/world_sentinel 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/role_min_nums/gate 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/role_min_nums/game 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/role_min_nums/world 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/role_min_nums/create_role 1

etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_join_servers/world_sentinel.world_sentinel_0 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_join_servers/gate.gate_0 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_join_servers/gate.gate_1 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_join_servers/game.game_0 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_join_servers/game.game_1 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_join_servers/world.world_0 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_join_servers/world.world_1 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_join_servers/create_role.create_role_0 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_join_servers/create_role.create_role_1 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_join_servers/match.match_0 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_join_servers/match.match_1 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_join_servers/room.room_0 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_join_servers/room.room_1 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_join_servers/fight.fight_0 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_join_servers/fight.fight_1 1

etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_work_servers/world.world_0 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_work_servers/world.world_1 1

etcdctl ${endpoints_flag} ls -r /${zone_name}
