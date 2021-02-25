#!/bin/bash

pre_dir=`pwd`
cd /shared/etcd_cluster

sh stop_all.sh
rm -rf /shared/etcd_cluster/run/*

cd ${pre_dir}