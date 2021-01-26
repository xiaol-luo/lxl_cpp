#!/bin/bash

pre_dir=`pwd`
cd {{ cluster.work_dir }}

{%- for node in cluster.node_list  %}

ps -ef | grep etcd | grep -v grep | grep config | grep file | grep {{ node.name }} | awk '{ print $2}' | xargs -rt kill -9

{%- endfor %}


sh ps_all.sh

cd ${pre_dir}