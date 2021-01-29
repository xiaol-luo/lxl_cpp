#!/bin/bash

# input map:  cluster

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

{%- for node in cluster.node_list  %}
mkdir -p {{ node.data_dir }}
{%- endfor %}

{%- for node in cluster.node_list  %}
nohup etcd --config-file {{ node.name }} > {{ node.log_file }} 2>&1 &
{%- endfor %}

echo "etcd cluster started"
sleep 5s

end_points={{ cluster.get_end_points() }}
etcdctl  --endpoints ${end_points} member list

if [ ${is_init} = true ]; then
    echo "{{ cluster.auth_pwd }}" | etcdctl --endpoints ${end_points} user add root
    etcdctl --endpoints ${end_points} auth enable
    echo "{{ cluster.auth_pwd }}" | etcdctl --endpoints ${end_points} -username root:{{ cluster.auth_pwd }} user add {{ cluster.auth_user }}
    etcdctl --endpoints ${end_points} -username root:{{ cluster.auth_pwd }} role add rw_all


{%- for dir in cluster.etcd_dirs  %}
    etcdctl --endpoints ${end_points} -username root:{{ cluster.auth_pwd }} role grant --readwrite --path {{ dir }} rw_all
{%- endfor %}

    etcdctl --endpoints ${end_points} -username root:{{ cluster.auth_pwd }} user grant --roles rw_all {{ cluster.auth_user }}
fi


sh ps_all.sh

cd ${pre_dir}


