#!/bin/bash

source /shared/mongo_cluster/config.sh
pre_dir=`pwd`
cd ${root_dir}

sh stop_all.sh

for idx in ${!rs_names[@]}
do
    rs_name=${rs_names[${idx}]}
    rs_from=${rs_froms[${idx}]}
    for ((i=0; i<${replica_num};i++))
    do
        node_id=`expr ${rs_from} + ${i}`
        mkdir -p "${run_dir}/db_${node_id}"
        cfg_file="${root_dir}/${rs_name}_${node_id}.conf"
        mongod -f ${cfg_file}
    done
done

mongos -f "mongos_${mongos_from}.conf"

sh ps.sh

cd ${pre_dir}

