#!/bin/bash

pre_dir=`pwd`
cd {{ cluster.work_dir }}

{%- for node in cluster.node_list  %}

ps -ef | grep -v grep | grep redis-server | grep cluster | grep 0.0.0.0:{{ node.port }} | awk '{ print $2}' | xargs -rt kill -9

{%- endfor %}


sh ps_all.sh

cd ${pre_dir}