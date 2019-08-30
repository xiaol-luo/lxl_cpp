#!/bin/bash

ps -ef | grep 'etcd'  | grep 'etcd_' | grep -v 'grep' | awk '{ print $2}' | xargs -t kill -9

