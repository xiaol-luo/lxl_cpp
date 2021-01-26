#!/bin/bash

pre_dir=`pwd`
cd {{ cluster.work_dir }}

{%- for node in cluster.node_list  %}

pid=`ps -ef | grep -v grep | grep redis-server | grep cluster | grep 0.0.0.0:{{ node.port }} | awk '{ print $2}' `
kill -9 ${pid}

{%- endfor %}


sh ps_all.sh

cd ${pre_dir}