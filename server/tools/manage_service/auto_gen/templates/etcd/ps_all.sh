#!/bin/bash

pre_dir=`pwd`
cd {{ cluster.work_dir }}

{%- for node in cluster.node_list  %}

ps -ef | grep etcd | grep -v grep | grep config | grep file | grep {{ node.name }}

{%- endfor %}

cd ${pre_dir}