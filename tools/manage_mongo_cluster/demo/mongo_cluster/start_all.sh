#!/bin/bash

source /shared/mongo_cluster/config.sh

typeset -l low_case_str
is_init=false
if [ $# > 1 ];then
	low_case_str=$1
	if [ ${low_case_str} = "init" ];then
		is_init=true
	fi
fi

pre_dir=`pwd`
cd ${root_dir}

sh stop_all.sh

for idx in ${!rs_names[@]}
do
    rs_name=${rs_names[${idx}]}
    rs_from=${rs_froms[${idx}]}
    for ((i=0; i<${replica_num};i++))
    do
        node_id=`expr ${rs_from} + ${i}`
        mkdir -p "${run_dir}/db_${node_id}"
        cfg_file="${root_dir}/${rs_name}_${node_id}.conf"
        mongod -f ${cfg_file}
    done
done

if [ ${is_init} = true ];then
	mongo -port 9000 -eval 'rs.initiate({ _id:"rs_cfg", members:[ {_id:0, host:"127.0.0.1:9000"}, {_id:1, host:"127.0.0.1:9001"}, {_id:2, host:"127.0.0.1:9002"} ] }); rs.slaveOk()' 
	mongo -port 9100 -eval 'rs.initiate({ _id:"rs_1", members:[ {_id:0, host:"127.0.0.1:9100"}, {_id:1, host:"127.0.0.1:9101"}, {_id:2, host:"127.0.0.1:9102"} ] }); rs.slaveOk()'
	mongo -port 9200 -eval 'rs.initiate({ _id:"rs_2", members:[ {_id:0, host:"127.0.0.1:9200"}, {_id:1, host:"127.0.0.1:9201"}, {_id:2, host:"127.0.0.1:9202"} ] }); rs.slaveOk()'
	mongo -port 9300 -eval 'rs.initiate({ _id:"rs_3", members:[ {_id:0, host:"127.0.0.1:9300"}, {_id:1, host:"127.0.0.1:9301"}, {_id:2, host:"127.0.0.1:9302"} ] }); rs.slaveOk()'
fi

mongos -f "mongos_${mongos_from}.conf"

if [ ${is_init} = true ];then
	mongo -port 9400 -eval 'sh.addShard("rs_1/127.0.0.1:9100,127.0.0.1:9101,127.0.0.1:9102")'
	mongo -port 9400 -eval 'sh.addShard("rs_2/127.0.0.1:9200,127.0.0.1:9201,127.0.0.1:9202")'
	mongo -port 9400 -eval 'sh.addShard("rs_3/127.0.0.1:9300,127.0.0.1:9301,127.0.0.1:9302")'
	#make collection shard
	mongo -port 9400 admin -eval 'db.runCommand({"enablesharding":"testsh"}); db.runCommand({"shardcollection":"testsh.role","key":{_id:"hashed"}})'
fi

sh ps.sh

cd ${pre_dir}

