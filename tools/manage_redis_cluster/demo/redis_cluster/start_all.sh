#!/bin/bash

typeset -l low_case_str
is_init=false
if [ $# -ge 1 ];then
	low_case_str=$1
	if [ ${low_case_str} = "init" ];then
		is_init=true
	fi
fi

source /shared/redis_cluster/config.sh
pre_dir=`pwd`
cd ${root_dir}

mkdir -p ${run_dir}

sh stop_all.sh

echo "execute start_all.sh"
for ((node_id=${redis_node_from}; node_id<=${redis_node_to}; node_id++  ))
do
    redis-server redis_${node_id}.conf
done 

if [ ${is_init} = true ]; then
    redis-trib create --replicas 1 127.0.0.1:7000 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005
fi

sh ps.sh

cd ${pre_dir}
