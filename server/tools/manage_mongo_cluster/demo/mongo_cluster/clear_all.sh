#!/bin/bash

pre_dir=`pwd`
cd /shared/mongo_cluster

sh stop_all.sh
rm -rf /shared/mongo_cluster/run/*

cd ${pre_dir}