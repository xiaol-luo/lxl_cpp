#!/bin/bash

script_root=`dirname "$0"`
cmd_help_script=$script_root/cmd_help.sh
sh ${cmd_help_script} ps $1

