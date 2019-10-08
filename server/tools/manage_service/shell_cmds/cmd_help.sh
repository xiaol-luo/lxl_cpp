#!/bin/bash

script_root=`dirname "$0"`
source $script_root/config.sh

echo $code_dir

python3 ${manage_service_script_path} $1 $2 --code_dir ${code_dir} --exe_dir ${exe_dir} --work_dir ${work_dir}
