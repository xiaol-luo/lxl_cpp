#!/bin/bash

source /shared/redis_cluster/config.sh
pre_dir=`pwd`
cd ${root_dir}

sh stop_all.sh

echo "execute start_all.sh"
for ((node_id=${redis_node_from}; node_id<=${redis_node_to}; node_id++  ))
do
    redis-server redis_${node_id}.conf
done 

sh ps.sh

cd ${pre_dir}