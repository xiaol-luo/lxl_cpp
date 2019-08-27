#!/bin/bash

echo "current running redis service:"
ps -ef | grep 'redis' | grep -v 'grep'