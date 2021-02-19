#!/bin/bash

pre_dir=`pwd`
cd /shared/zone/zone_0/redis_cluster

ps -ef | grep -v grep | grep redis-server | grep cluster | grep 0.0.0.0:7000 | awk '{ print $2}' | xargs -rt kill -9

ps -ef | grep -v grep | grep redis-server | grep cluster | grep 0.0.0.0:7001 | awk '{ print $2}' | xargs -rt kill -9

ps -ef | grep -v grep | grep redis-server | grep cluster | grep 0.0.0.0:7002 | awk '{ print $2}' | xargs -rt kill -9

ps -ef | grep -v grep | grep redis-server | grep cluster | grep 0.0.0.0:7003 | awk '{ print $2}' | xargs -rt kill -9

ps -ef | grep -v grep | grep redis-server | grep cluster | grep 0.0.0.0:7004 | awk '{ print $2}' | xargs -rt kill -9

ps -ef | grep -v grep | grep redis-server | grep cluster | grep 0.0.0.0:7005 | awk '{ print $2}' | xargs -rt kill -9


sh ps_all.sh

cd ${pre_dir}