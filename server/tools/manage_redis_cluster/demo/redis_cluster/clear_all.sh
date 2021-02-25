#!/bin/bash

pre_dir=`pwd`
cd /shared/redis_cluster

sh stop_all.sh
rm -rf /shared/redis_cluster/run/*

cd ${pre_dir}