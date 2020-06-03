#!/bin/bash

sh /shared/etcd_cluster/$1_all.sh $2
sh /shared/redis_cluster/$1_all.sh $2
sh /shared/mongo_cluster/$1_all.sh $2
