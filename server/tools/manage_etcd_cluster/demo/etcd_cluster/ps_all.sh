#!/bin/bash

pre_dir=`pwd`
cd /shared/etcd_cluster

ps -ef | grep etcd | grep -v grep | grep config | grep file | grep etcd_0

ps -ef | grep etcd | grep -v grep | grep config | grep file | grep etcd_1

ps -ef | grep etcd | grep -v grep | grep config | grep file | grep etcd_2

cd ${pre_dir}