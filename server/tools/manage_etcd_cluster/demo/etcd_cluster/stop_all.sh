#!/bin/bash

pre_dir=`pwd`
cd /shared/zone/zone_0/etcd_cluster

ps -ef | grep etcd | grep -v grep | grep config | grep file | grep etcd_0 | awk '{ print $2}' | xargs -rt kill -9

ps -ef | grep etcd | grep -v grep | grep config | grep file | grep etcd_1 | awk '{ print $2}' | xargs -rt kill -9

ps -ef | grep etcd | grep -v grep | grep config | grep file | grep etcd_2 | awk '{ print $2}' | xargs -rt kill -9


sh ps_all.sh

cd ${pre_dir}