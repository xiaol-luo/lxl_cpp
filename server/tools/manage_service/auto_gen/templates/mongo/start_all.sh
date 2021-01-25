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
cd {{ cluster.work_dir }}

sh stop_all.sh


{%- for replica in cluster.data_replica_list  %}
  {%- for node in replica.node_list  %}
mkdir -p {{ node.db_file_path }}
cfg_file="{{ cluster.work_dir }}/{{ node.name }}"
if [ ${is_init} = true ]; then
  mongod -f ${cfg_file}
else
  mongod  --keyFile ${mongodb_keyfile} -f ${cfg_file}
fi

  {%- endfor %}
{%- endfor %}

if [ ${is_init} = true ];then
{%- for replica in cluster.data_replica_list  %}
  {{ replica.get_rs_init_cmd() }}
{%- endfor %}
  {{ cluster.cfg_replica.get_rs_init_cmd() }}
fi

echo "setup mongs begin"
if [ ${is_init} = true ]; then
	rm -f ${mongodb_keyfile}
	openssl rand -base64 741 > ${mongodb_keyfile}
	chmod 400 ${mongodb_keyfile}
	mongos -f "{{ client.name }}"
else
	mongos --keyFile ${mongodb_keyfile} -f "{{ client.name }}"
fi
echo "setup mongs end"

if [ ${is_init} = true ];then
{%- for replica in cluster.data_replica_list  %}
    mongo -port {{ client.port }} -eval '{{ replica.get_rs_add_shard_raw_cmd() }}'
{%- endfor %}

# make collection shard
{%- for db in cluster.get_shard_dbs()  %}
    mongo -port {{ client.port }} admin -eval 'db.runCommand({enablesharding:"{{ db }}"})'
{%- endfor %}
{%- for elem in cluster.shard_list  %}
    mongo -port {{ client.port }} admin -eval 'db.runCommand({shardcollection:"{{ elem.db }}.{{ elem.coll }}",key:{ {{ elem.coll }}:1 }, unique:{{ elem.unique|lower }} })'
{%- endfor %}

# create index
	# mongo -port {{ client.port }} game_zone_0 -eval 'db.role.ensureIndex({user_id:1}, {unique:true}); db.role.getIndexes()'

# create users
	# mongo -port {{ client.port }} admin -eval 'db.createUser({ "user":"admin", "pwd":"xiaolzz", "roles":[ { role: "userAdminAnyDatabase", db: "admin" } ] })'
	mongo -port {{ client.port }} admin -eval 'db.createUser({ "user":"root", "pwd":"{{ pwd }}", "roles":["root"] })'
	mongo -port {{ client.port }} admin -eval 'db.createUser({ "user":"{{ user }}", "pwd":"{{ pwd }}", "roles":[ { role: "readWriteAnyDatabase", db: "admin" } ] })'

	sleep 5
	sh start_all.sh
else
	echo "execute cmd on database testsh db.role.count({}), retsult is:"
	mongo -port {{ client.port }} -u lxl -p xiaolzz --authenticationDatabase admin testsh --eval 'db.role.count({})'
	sh ps.sh
fi

cd ${pre_dir}

