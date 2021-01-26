#!/bin/bash

pre_dir=`pwd`
cd {{ cluster.work_dir }}

pid_files=`find . -name "*.pid"`
for pid_file in ${pid_files}
do
    cat ${pid_file} | xargs -rt kill -9
    rm -f ${pid_file}
done

sh ps_all.sh

cd ${pre_dir}