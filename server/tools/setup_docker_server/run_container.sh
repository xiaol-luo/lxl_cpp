docker run --name test_lxl  -dit -v /shared/docker/data_dir/:/shared -p 30003:30003 -p 32003:32003 -p 31002:31002 -p 31005:31005 -p 35002:35002 -p 35005:35005 -p 42002:42002 -p 42005:42005 lxl_cxx/centos /bin/bash

docker exec -it test_lxl /bin/bash
