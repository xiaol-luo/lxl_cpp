#!/bin/bash

pre_dir=`pwd`
cd /shared/zone/zone_0/etcd_cluster

sh stop_all.sh
rm -rf /shared/zone/zone_0/etcd_cluster/run/*

cd ${pre_dir}