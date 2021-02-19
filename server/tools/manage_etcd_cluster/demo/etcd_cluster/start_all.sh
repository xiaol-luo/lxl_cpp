#!/bin/bash

# input map:  cluster

# source /shared/mongo_cluster/config.sh

mongodb_keyfile=./mongodb-keyfile

is_init=false

typeset -l low_case_str
if [ $# -ge 1 ];then
	low_case_str=$1
	if [ ${low_case_str} = "init" ];then
		is_init=true
	fi
fi

pre_dir=`pwd`
cd /shared/zone/zone_0/etcd_cluster

sh stop_all.sh
mkdir -p /shared/zone/zone_0/etcd_cluster/run/etcd_0
mkdir -p /shared/zone/zone_0/etcd_cluster/run/etcd_1
mkdir -p /shared/zone/zone_0/etcd_cluster/run/etcd_2
nohup etcd --config-file etcd_0 > /shared/zone/zone_0/etcd_cluster/run/etcd_0.log 2>&1 &
nohup etcd --config-file etcd_1 > /shared/zone/zone_0/etcd_cluster/run/etcd_1.log 2>&1 &
nohup etcd --config-file etcd_2 > /shared/zone/zone_0/etcd_cluster/run/etcd_2.log 2>&1 &

echo "etcd cluster started"
sleep 5s

end_points=//127.0.0.1:8100,//127.0.0.1:8200,//127.0.0.1:8300
etcdctl  --endpoints ${end_points} member list

if [ ${is_init} = true ]; then
    echo "xiaolzz" | etcdctl --endpoints ${end_points} user add root
    etcdctl --endpoints ${end_points} auth enable
    echo "xiaolzz" | etcdctl --endpoints ${end_points} -username root:xiaolzz user add lxl
    etcdctl --endpoints ${end_points} -username root:xiaolzz role add rw_all
    etcdctl --endpoints ${end_points} -username root:xiaolzz role grant --readwrite --path /zone_0/* rw_all

    etcdctl --endpoints ${end_points} -username root:xiaolzz user grant --roles rw_all lxl
fi


sh ps_all.sh

cd ${pre_dir}

