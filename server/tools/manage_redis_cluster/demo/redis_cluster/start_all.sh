#!/bin/bash

# input map:  cluster

is_init=false

typeset -l low_case_str
if [ $# -ge 1 ];then
	low_case_str=$1
	if [ ${low_case_str} = "init" ];then
		is_init=true
	fi
fi

pre_dir=`pwd`
cd /shared/redis_cluster

sh stop_all.sh


mkdir -p /shared/redis_cluster/run
redis-server redis_7000
redis-server redis_7001
redis-server redis_7002
redis-server redis_7003
redis-server redis_7004
redis-server redis_7005

echo "redis cluster started"
sleep 5s

if [ ${is_init} = true ]; then
  echo "yes" |  redis-trib create --replicas 1  127.0.0.1:7000  127.0.0.1:7001  127.0.0.1:7002  127.0.0.1:7003  127.0.0.1:7004  127.0.0.1:7005
fi
	redis-cli -p 7000 -c config set requirepass xiaolzz
	redis-cli -p 7001 -c config set requirepass xiaolzz
	redis-cli -p 7002 -c config set requirepass xiaolzz
	redis-cli -p 7003 -c config set requirepass xiaolzz
	redis-cli -p 7004 -c config set requirepass xiaolzz
	redis-cli -p 7005 -c config set requirepass xiaolzz

sh ps_all.sh

cd ${pre_dir}

