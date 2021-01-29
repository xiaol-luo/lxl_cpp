#!/bin/bash

# input map:  cluster

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


mkdir -p {{ cluster.run_dir }}

{%- for node in cluster.node_list  %}
redis-server {{ node.name }}
{%- endfor %}

echo "redis cluster started"
sleep 5s

if [ ${is_init} = true ]; then
  echo "yes" |  redis-trib create --replicas 1 {%- for node in cluster.node_list  %}  {{ node.peer_ip }}:{{ node.port }} {%- endfor %}
fi

{%- for node in cluster.node_list  %}
	redis-cli -p {{ node.port }} -c config set requirepass {{ cluster.auth_pwd }}
{%- endfor %}

sh ps_all.sh

cd ${pre_dir}


