#!/bin/bash

source /shared/redis_cluster/config.sh
pre_dir=`pwd`
cd ${root_dir}

echo "execute stop_all.sh"
pid_files=`find ${run_dir} -name '*.pid'`
for pid_file in ${pid_files} 
do
    cat ${pid_file} | xargs kill -9 
    rm -f ${pid_file}
done 

sh ps.sh

cd ${pre_dir}