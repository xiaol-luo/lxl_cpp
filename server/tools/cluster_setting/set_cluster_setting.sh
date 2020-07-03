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

etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_join_servers/world_sentinel.sentinel_0 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_join_servers/gate.gate_0 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_join_servers/game.game_0 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_join_servers/world.luo 1
etcdctl ${endpoints_flag} set ${zone_setting_path}/allow_join_servers/create_role.create_role_0 1

etcdctl ${endpoints_flag} ls -r /${zone_name}
