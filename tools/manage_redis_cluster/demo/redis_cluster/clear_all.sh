#!/bin/bash

source /shared/redis_cluster/config.sh
pre_dir=`pwd`
cd ${root_dir}

echo ${root_dir}
sh stop_all.sh

rm -rf ${run_dir}/*

cd ${pre_dir}

