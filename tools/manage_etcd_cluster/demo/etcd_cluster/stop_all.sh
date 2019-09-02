#!/bin/bash

for pid in `ps -ef | grep 'etcd'  | grep 'etcd_' | grep -v 'grep' | awk '{ print $2}'`
do
    kill -9 ${pid}
done

