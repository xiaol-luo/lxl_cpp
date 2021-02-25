#!/bin/bash

pre_dir=`pwd`
cd /shared/redis_cluster

ps -ef | grep -v grep | grep redis-server | grep cluster | grep 0.0.0.0:7000

ps -ef | grep -v grep | grep redis-server | grep cluster | grep 0.0.0.0:7001

ps -ef | grep -v grep | grep redis-server | grep cluster | grep 0.0.0.0:7002

ps -ef | grep -v grep | grep redis-server | grep cluster | grep 0.0.0.0:7003

ps -ef | grep -v grep | grep redis-server | grep cluster | grep 0.0.0.0:7004

ps -ef | grep -v grep | grep redis-server | grep cluster | grep 0.0.0.0:7005

cd ${pre_dir}