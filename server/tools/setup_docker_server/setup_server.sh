#!/bin/bash

python3 /shared/lxl_cpp/server/tools/manage_service/manage_service.py \
	--code_dir /shared/lxl_cpp/server/ \
	--exe_dir /shared/build \
	--work_dir /shared/zone create zone_0
	
sh /shared/zone/zone_0/redis_cluster/clear_all.sh
sh /shared/zone/zone_0/redis_cluster/start_all.sh init

sh /shared/zone/zone_0/etcd_cluster/clear_all.sh
sh /shared/zone/zone_0/etcd_cluster/start_all.sh init

sh /shared/zone/zone_0/mongo_cluster/clear_all.sh
sh /shared/zone/zone_0/mongo_cluster/start_all.sh init
sh /shared/lxl_cpp/server/tools/cluster_setting/set_cluster_setting.sh

sh /shared/zone/zone_0/servers/start.sh
