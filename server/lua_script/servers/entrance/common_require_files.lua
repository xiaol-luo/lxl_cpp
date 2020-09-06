
return {

    require("servers.common.include"),

    "servers.server_impl.server_def",
    "servers.server_impl.server_base",
    "servers.server_impl.game_server_base",

    require("servers.services.include"),

    "libs.etcd_watch.etcd_watch_def",
    "libs.etcd_watch.etcd_watch_result",
    "libs.etcd_watch.etcd_watcher",

    "libs.etcd_result.etcd_result_def",
    "libs.etcd_result.etcd_result",
    "libs.etcd_result.etcd_result_node",
    "libs.etcd_result.etcd_result_dir",
    "libs.etcd_result.etcd_result_node_visitor",

}
