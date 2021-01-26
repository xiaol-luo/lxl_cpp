#!/bin/bash

pre_dir=`pwd`
cd {{ cluster.work_dir }}

sh stop_all.sh
rm -rf {{ cluster.run_dir }}/*

cd ${pre_dir}