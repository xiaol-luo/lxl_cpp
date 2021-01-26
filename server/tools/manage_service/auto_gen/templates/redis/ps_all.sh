#!/bin/bash

pre_dir=`pwd`
cd {{ cluster.work_dir }}

{%- for node in cluster.node_list  %}

ps -ef | grep -v grep | grep redis-server | grep cluster | grep 0.0.0.0:{{ node.port }}

{%- endfor %}

cd ${pre_dir}