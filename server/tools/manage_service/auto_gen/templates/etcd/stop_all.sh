#!/bin/bash

pre_dir=`pwd`
cd {{ cluster.work_dir }}

{%- for node in cluster.node_list  %}

pid=`ps -ef | grep etcd | grep -v grep | grep config | grep file | grep {{ node.name }} | awk '{ print $2}' `
kill -9 ${pid}

{%- endfor %}


sh ps_all.sh

cd ${pre_dir}