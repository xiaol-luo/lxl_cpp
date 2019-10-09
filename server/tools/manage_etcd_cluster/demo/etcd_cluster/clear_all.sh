#!/bin/bash

script_root=`dirname "$0"`
pre_dir=`pwd`
cd ${script_root}

sh stop_all.sh
rm -rf run/*

cd ${pre_dir}
