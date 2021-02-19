#!/bin/bash

# input map:  cluster, client, user, pwd

# source /shared/mongo_cluster/config.sh

mongodb_keyfile=./mongodb-keyfile

is_init=false

typeset -l low_case_str
if [ $# -ge 1 ];then
	low_case_str=$1
	if [ ${low_case_str} = "init" ];then
		is_init=true
	fi
fi

pre_dir=`pwd`
cd /shared/zone/zone_0/mongo_cluster

sh stop_all.sh
mkdir -p /shared/zone/zone_0/mongo_cluster/run/db_file_9010
if [ ${is_init} = true ]; then
  mongod -f /shared/zone/zone_0/mongo_cluster/rs_cfg_9010
else
  mongod  --keyFile ${mongodb_keyfile} -f /shared/zone/zone_0/mongo_cluster/rs_cfg_9010
fi
mkdir -p /shared/zone/zone_0/mongo_cluster/run/db_file_9011
if [ ${is_init} = true ]; then
  mongod -f /shared/zone/zone_0/mongo_cluster/rs_cfg_9011
else
  mongod  --keyFile ${mongodb_keyfile} -f /shared/zone/zone_0/mongo_cluster/rs_cfg_9011
fi
mkdir -p /shared/zone/zone_0/mongo_cluster/run/db_file_9012
if [ ${is_init} = true ]; then
  mongod -f /shared/zone/zone_0/mongo_cluster/rs_cfg_9012
else
  mongod  --keyFile ${mongodb_keyfile} -f /shared/zone/zone_0/mongo_cluster/rs_cfg_9012
fi
mkdir -p /shared/zone/zone_0/mongo_cluster/run/db_file_9001
if [ ${is_init} = true ]; then
  mongod -f /shared/zone/zone_0/mongo_cluster/rs_db_0_9001
else
  mongod  --keyFile ${mongodb_keyfile} -f /shared/zone/zone_0/mongo_cluster/rs_db_0_9001
fi
mkdir -p /shared/zone/zone_0/mongo_cluster/run/db_file_9002
if [ ${is_init} = true ]; then
  mongod -f /shared/zone/zone_0/mongo_cluster/rs_db_0_9002
else
  mongod  --keyFile ${mongodb_keyfile} -f /shared/zone/zone_0/mongo_cluster/rs_db_0_9002
fi
mkdir -p /shared/zone/zone_0/mongo_cluster/run/db_file_9003
if [ ${is_init} = true ]; then
  mongod -f /shared/zone/zone_0/mongo_cluster/rs_db_0_9003
else
  mongod  --keyFile ${mongodb_keyfile} -f /shared/zone/zone_0/mongo_cluster/rs_db_0_9003
fi
mkdir -p /shared/zone/zone_0/mongo_cluster/run/db_file_9004
if [ ${is_init} = true ]; then
  mongod -f /shared/zone/zone_0/mongo_cluster/rs_db_1_9004
else
  mongod  --keyFile ${mongodb_keyfile} -f /shared/zone/zone_0/mongo_cluster/rs_db_1_9004
fi
mkdir -p /shared/zone/zone_0/mongo_cluster/run/db_file_9005
if [ ${is_init} = true ]; then
  mongod -f /shared/zone/zone_0/mongo_cluster/rs_db_1_9005
else
  mongod  --keyFile ${mongodb_keyfile} -f /shared/zone/zone_0/mongo_cluster/rs_db_1_9005
fi
mkdir -p /shared/zone/zone_0/mongo_cluster/run/db_file_9006
if [ ${is_init} = true ]; then
  mongod -f /shared/zone/zone_0/mongo_cluster/rs_db_1_9006
else
  mongod  --keyFile ${mongodb_keyfile} -f /shared/zone/zone_0/mongo_cluster/rs_db_1_9006
fi
mkdir -p /shared/zone/zone_0/mongo_cluster/run/db_file_9007
if [ ${is_init} = true ]; then
  mongod -f /shared/zone/zone_0/mongo_cluster/rs_db_2_9007
else
  mongod  --keyFile ${mongodb_keyfile} -f /shared/zone/zone_0/mongo_cluster/rs_db_2_9007
fi
mkdir -p /shared/zone/zone_0/mongo_cluster/run/db_file_9008
if [ ${is_init} = true ]; then
  mongod -f /shared/zone/zone_0/mongo_cluster/rs_db_2_9008
else
  mongod  --keyFile ${mongodb_keyfile} -f /shared/zone/zone_0/mongo_cluster/rs_db_2_9008
fi
mkdir -p /shared/zone/zone_0/mongo_cluster/run/db_file_9009
if [ ${is_init} = true ]; then
  mongod -f /shared/zone/zone_0/mongo_cluster/rs_db_2_9009
else
  mongod  --keyFile ${mongodb_keyfile} -f /shared/zone/zone_0/mongo_cluster/rs_db_2_9009
fi



if [ ${is_init} = true ];then
  mongo -port 9001 -eval 'rs.initiate({ _id:"rs_db_0", members:[ {_id:0, host:"127.0.0.1:9001"},{_id:1, host:"127.0.0.1:9002"},{_id:2, host:"127.0.0.1:9003"} ] }); rs.slaveOk()'
  mongo -port 9004 -eval 'rs.initiate({ _id:"rs_db_1", members:[ {_id:0, host:"127.0.0.1:9004"},{_id:1, host:"127.0.0.1:9005"},{_id:2, host:"127.0.0.1:9006"} ] }); rs.slaveOk()'
  mongo -port 9007 -eval 'rs.initiate({ _id:"rs_db_2", members:[ {_id:0, host:"127.0.0.1:9007"},{_id:1, host:"127.0.0.1:9008"},{_id:2, host:"127.0.0.1:9009"} ] }); rs.slaveOk()'
  mongo -port 9010 -eval 'rs.initiate({ _id:"rs_cfg", members:[ {_id:0, host:"127.0.0.1:9010"},{_id:1, host:"127.0.0.1:9011"},{_id:2, host:"127.0.0.1:9012"} ] }); rs.slaveOk()'
fi

echo "setup mongs begin"
if [ ${is_init} = true ]; then
	rm -f ${mongodb_keyfile}
	openssl rand -base64 741 > ${mongodb_keyfile}
	chmod 400 ${mongodb_keyfile}
	mongos -f "mongos_9400"
else
	mongos --keyFile ${mongodb_keyfile} -f "mongos_9400"
fi
echo "setup mongs end"

if [ ${is_init} = true ];then
    mongo -port 9400 -eval 'sh.addShard("rs_db_0/127.0.0.1:9001,127.0.0.1:9002,127.0.0.1:9003")'
    mongo -port 9400 -eval 'sh.addShard("rs_db_1/127.0.0.1:9004,127.0.0.1:9005,127.0.0.1:9006")'
    mongo -port 9400 -eval 'sh.addShard("rs_db_2/127.0.0.1:9007,127.0.0.1:9008,127.0.0.1:9009")'

# make collection shard
    mongo -port 9400 admin -eval 'db.runCommand({enablesharding:"game_zone_0"})'
    mongo -port 9400 admin -eval 'db.runCommand({enablesharding:"login_zone_0"})'
    mongo -port 9400 admin -eval 'db.runCommand({shardcollection:"game_zone_0.role",key:{ role:1 }, unique:true })'
    mongo -port 9400 admin -eval 'db.runCommand({shardcollection:"login_zone_0.account",key:{ account:1 }, unique:true })'

# create index
	# mongo -port 9400 game_zone_0 -eval 'db.role.ensureIndex({user_id:1}, {unique:true}); db.role.getIndexes()'

# create users
	# mongo -port 9400 admin -eval 'db.createUser({ "user":"admin", "pwd":"xiaolzz", "roles":[ { role: "userAdminAnyDatabase", db: "admin" } ] })'
	mongo -port 9400 admin -eval 'db.createUser({ "user":"root", "pwd":"xiaolzz", "roles":["root"] })'
	mongo -port 9400 admin -eval 'db.createUser({ "user":"lxl", "pwd":"xiaolzz", "roles":[ { role: "readWriteAnyDatabase", db: "admin" } ] })'

	sleep 5
	sh start_all.sh
else
	echo "execute cmd on database testsh db.role.count({}), retsult is:"
	mongo -port 9400 -u lxl -p xiaolzz --authenticationDatabase admin testsh --eval 'db.role.count({})'
	sh ps_all.sh
fi

cd ${pre_dir}