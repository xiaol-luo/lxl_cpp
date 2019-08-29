#!/bin/bash

source /shared/mongo_cluster/config.sh
pre_dir=`pwd`
cd ${root_dir}

mongo -port 9000 -eval 'rs.initiate({ _id:"rs_cfg", members:[ {_id:0, host:"127.0.0.1:9000"}, {_id:1, host:"127.0.0.1:9001"}, {_id:2, host:"127.0.0.1:9002"} ] })' 
mongo -port 9100 -eval 'rs.initiate({ _id:"rs_1", members:[ {_id:0, host:"127.0.0.1:9100"}, {_id:1, host:"127.0.0.1:9101"}, {_id:2, host:"127.0.0.1:9102"} ] })'
mongo -port 9200 -eval 'rs.initiate({ _id:"rs_2", members:[ {_id:0, host:"127.0.0.1:9200"}, {_id:1, host:"127.0.0.1:9201"}, {_id:2, host:"127.0.0.1:9202"} ] })'
mongo -port 9300 -eval 'rs.initiate({ _id:"rs_3", members:[ {_id:0, host:"127.0.0.1:9300"}, {_id:1, host:"127.0.0.1:9301"}, {_id:2, host:"127.0.0.1:9302"} ] })'


cd ${pre_dir}
