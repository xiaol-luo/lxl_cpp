#!/bin/bash


typeset -l low_case_str
is_init=false
if [ $# -ge 1 ];then
	low_case_str=$1
	if [ ${low_case_str} = "init" ];then
		is_init=true
	fi
fi

mkdir -p run/etcd_1
mkdir -p run/etcd_2
mkdir -p run/etcd_3

sh stop_all.sh

nohup etcd --config-file etcd_1.conf.yaml > run/logfile_1.log 2>&1 &
nohup etcd --config-file etcd_2.conf.yaml > run/logfile_2.log 2>&1 &
nohup etcd --config-file etcd_3.conf.yaml > run/logfile_3.log 2>&1 &
echo "etcd cluster started"

sleep 5s

end_points=//127.0.0.1:8100,//127.0.0.1:8200,//127.0.0.1:8300

etcdctl  --endpoints ${end_points} member list

if [ ${is_init} = true ]; then
    etcdctl --endpoints ${end_points} user add root
    etcdctl --endpoints ${end_points} auth enable
    etcdctl --endpoints ${end_points} -username root:xiaolzz user add lxl
    etcdctl --endpoints ${end_points} -username root:xiaolzz role add rw_all
    etcdctl --endpoints ${end_points} -username root:xiaolzz role grant --readwrite --path / rw_all
    etcdctl --endpoints ${end_points} -username root:xiaolzz user grant --roles rw_all lxl
fi



