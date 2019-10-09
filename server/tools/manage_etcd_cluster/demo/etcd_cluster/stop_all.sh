#!/bin/bash

for pid in `ps -ef | grep 'etcd'  | grep 'etcd_'  | grep 'peerURLs' | grep -v 'grep' | awk '{ print $2}'`
do
    kill -9 ${pid}
done

