#!/bin/bash

mkdir -p run/etcd_1
mkdir -p run/etcd_2
mkdir -p run/etcd_3

sh stop_all.sh

nohup etcd --config-file etcd_1.conf.yaml > run/logfile_1.log 2>&1 &
nohup etcd --config-file etcd_2.conf.yaml > run/logfile_2.log 2>&1 &
nohup etcd --config-file etcd_3.conf.yaml > run/logfile_3.log 2>&1 &


sleep 5s
etcdctl  --endpoints //127.0.0.1:8100,//127.0.0.1:8200,//127.0.0.1:8300 member list

