#!/bin/bash

source /shared/redis_cluster/config.sh
pre_dir=`pwd`
cd ${root_dir}


echo "execute stop_all.sh"
for pid_file in `ls ${run_dir}/*.pid` 
do
    cat ${pid_file} | xargs kill -9 
done 

sh ps.sh

cd ${pre_dir}