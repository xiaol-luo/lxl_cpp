
#!/bin/bash

echo "current running mongo service:"
# ps -ef | grep 'mongo' | grep -v 'grep'

pid_files=`find . -name "pidfile_*.pid"`
for pid_file in ${pid_files}
do
    pid=`cat ${pid_file}`
    ps -ef | grep 'mongo' | grep -v 'grep' | grep ${pid}
done