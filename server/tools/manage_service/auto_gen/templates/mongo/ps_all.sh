#!/bin/bash

pre_dir=`pwd`
cd {{ cluster.work_dir }}

echo "current running mongo service:"
# ps -ef | grep 'mongo' | grep -v 'grep'

pid_files=`find . -name "*.pid"`
for pid_file in ${pid_files}
do
    pid=`cat ${pid_file}`
    ps -ef | grep 'mongo' | grep -v 'grep' | grep ${pid}
done

cd ${pre_dir}