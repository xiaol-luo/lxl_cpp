root_dir="/shared/mongo_cluster"
run_dir="/shared/mongo_cluster/run"

mongos_from=9400

replica_num=3
declare -a rs_names=("rs_cfg" "rs_1" "rs_2" "rs_3")
declare -a rs_froms=(9000 9100 9200 9300)

