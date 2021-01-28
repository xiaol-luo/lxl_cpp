import auto_gen
import os
import config

from .server_help import ServerHelper

def create_etcd_cluster(parse_ret):
    cluster_setting = config.gen_etcd_setting(parse_ret)
    for node in cluster_setting.node_list:
        is_ok, ret_txt = auto_gen.render("etcd/etcd.conf", {
            "node": node,
            "cluster": cluster_setting,
        })
        ret_file_path = os.path.join(cluster_setting.work_dir, node.name)
        config.write_file(ret_file_path, ret_txt)
    is_ok, cfg_content = auto_gen.render("etcd/start_all.sh", {
        "cluster": cluster_setting,
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "start_all.sh"), cfg_content)
    is_ok, cfg_content = auto_gen.render("etcd/stop_all.sh", {
        "cluster": cluster_setting
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "stop_all.sh"), cfg_content)
    is_ok, cfg_content = auto_gen.render("etcd/ps_all.sh", {
        "cluster": cluster_setting
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "ps_all.sh"), cfg_content)
    is_ok, cfg_content = auto_gen.render("etcd/clear_all.sh", {
        "cluster": cluster_setting
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "clear_all.sh"), cfg_content)


def create_redis_cluster(parse_ret):
    cluster_setting = config.gen_redis_setting(parse_ret)
    for node in cluster_setting.node_list:
        is_ok, ret_txt = auto_gen.render("redis/redis.conf", {
            "node": node,
            "cluster": cluster_setting,
        })
        ret_file_path = os.path.join(cluster_setting.work_dir, node.name)
        config.write_file(ret_file_path, ret_txt)
    is_ok, cfg_content = auto_gen.render("redis/start_all.sh", {
        "cluster": cluster_setting,
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "start_all.sh"), cfg_content)
    is_ok, cfg_content = auto_gen.render("redis/stop_all.sh", {
        "cluster": cluster_setting
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "stop_all.sh"), cfg_content)
    is_ok, cfg_content = auto_gen.render("redis/ps_all.sh", {
        "cluster": cluster_setting
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "ps_all.sh"), cfg_content)
    is_ok, cfg_content = auto_gen.render("redis/clear_all.sh", {
        "cluster": cluster_setting
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "clear_all.sh"), cfg_content)


def create_mongo_cluster(parse_ret):
    cluster_setting = config.gen_mongo_setting(parse_ret)
    for node in cluster_setting.cfg_replica.node_list:
        is_ok, cfg_content = auto_gen.render("mongo/mongod.conf", {
            "node": node,
            "cluster": cluster_setting,
            "replica": cluster_setting.cfg_replica,
        })
        config.write_file("{}/{}".format(cluster_setting.work_dir, node.name), cfg_content)
    for replica in cluster_setting.data_replica_list:
        for node in replica.node_list:
            is_ok, cfg_content = auto_gen.render("mongo/mongod.conf", {
                "node": node,
                "cluster": cluster_setting,
                "replica": replica,
            })
            config.write_file("{}/{}".format(cluster_setting.work_dir, node.name), cfg_content)
    for node in cluster_setting.client_list:
        is_ok, cfg_content = auto_gen.render("mongo/mongos.conf", {
            "node": node,
            "cluster": cluster_setting,
        })
        config.write_file("{}/{}".format(cluster_setting.work_dir, node.name), cfg_content)

    is_ok, cfg_content = auto_gen.render("mongo/start_all.sh", {
        "client": cluster_setting.get_prefer_client(),
        "cluster": cluster_setting,
        "user": "lxl",
        "pwd": "xiaolzz",
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "start_all.sh"), cfg_content)
    is_ok, cfg_content = auto_gen.render("mongo/stop_all.sh", {
        "cluster": cluster_setting
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "stop_all.sh"), cfg_content)
    is_ok, cfg_content = auto_gen.render("mongo/ps_all.sh", {
        "cluster": cluster_setting
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "ps_all.sh"), cfg_content)
    is_ok, cfg_content = auto_gen.render("mongo/clear_all.sh", {
        "cluster": cluster_setting
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "clear_all.sh"), cfg_content)


def create_game_server(parse_ret):
    all_setting = config.gen_server_setting(parse_ret)
    for svr_role, svr_node_list in all_setting.items():
        for svr_node in svr_node_list:
            svr_help = ServerHelper(parse_ret, svr_node)
            svr_help.setup_server()
            '''
            is_ok, cfg_content = auto_gen.render("server/server.xml", {
                "node": svr_node
            })
            config.write_file("{}/{}".format(config.cal_path_zone_server_dir(parse_ret, svr_node.name),
                               "game_config.xml"), cfg_content)
                               '''


def create_zone(parse_ret):
    # os.makedirs(config.cal_zone_dir_path(parse_ret), exist_ok=True)

    # os.makedirs(os.path.dirname(config.cal_zone_script_dir_path(parse_ret)), exist_ok=True)
    # config.relink(config.cal_zone_script_dir_path(parse_ret), os.path.join(parse_ret.code_dir, "lua_script"), True)

    # os.makedirs(os.path.dirname(config.cal_zone_proto_dir_path(parse_ret)), exist_ok=True)
    # config.relink(config.cal_zone_proto_dir_path(parse_ret), os.path.join(parse_ret.code_dir, "datas/proto"), True)

    create_etcd_cluster(parse_ret)
    create_redis_cluster(parse_ret)
    create_mongo_cluster(parse_ret)
    create_game_server(parse_ret)

