#!/bin/bash

pre_dir=`pwd`
cd {{ cluster.work_dir }}

pid_files=`find . -name "pidfile_*.pid"`
for pid_file in ${pid_files}
do
    cat ${pid_file} | xargs -t kill -9
    rm -f ${pid_file}
done

sh ps.sh

cd ${pre_dir}