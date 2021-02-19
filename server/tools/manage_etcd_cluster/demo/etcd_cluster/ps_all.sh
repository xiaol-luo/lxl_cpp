#!/bin/bash

pre_dir=`pwd`
cd /shared/zone/zone_0/etcd_cluster

ps -ef | grep etcd | grep -v grep | grep config | grep file | grep etcd_0

ps -ef | grep etcd | grep -v grep | grep config | grep file | grep etcd_1

ps -ef | grep etcd | grep -v grep | grep config | grep file | grep etcd_2

cd ${pre_dir}