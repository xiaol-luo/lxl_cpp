local files = {
    "common.log",
    "common.error_handler",

    "libs.functional",
    "libs.class",
    "libs.string_ext",
    "libs.table_ext",
    "libs.type_check",
    "libs.assert",
    "libs.path_ext",
    "libs.random",
    "libs.xml2lua.xml2lua_ext",
    "libs.hotfix",
    "libs.sequencer",

    "rapidjson",
    "pb",
    "lpeg",
    "lfs",

    "common.date_time",
    "common.timer.timer",
    "common.timer.timer_proxy",
    "common.event.event_mgr",
    "common.event.event_proxy",
    "common.event.event_binder",

    "common.consistent_hash.consistent_hash",

    "libs.coroutine_ex.coroutine_ex_def",
    "libs.coroutine_ex.coroutine_ex",
    "libs.coroutine_ex.coroutine_ex_mgr",

    "libs.net.net_handler",
    "libs.net.net_cnn",
    "libs.net.net_listen",
    "libs.net.pid_bin_cnn",
    "libs.net.http_rsp_cnn",
    "libs.net.net",
    "libs.net.net_handler_map",
    "libs.net.cnn_handler_map",

    "libs.http.http_def",
    "libs.http.http_service",
    "libs.http.http_client",

    "libs.etcd.etcd_client_def",
    "libs.etcd.etcd_client",
    "libs.etcd.etcd_client_op_base",
    "libs.etcd.etcd_client_op_delete",
    "libs.etcd.etcd_client_op_get",
    "libs.etcd.etcd_client_op_set",
    "libs.etcd.etcd_client_result",
    "libs.etcd.etcd_client_cxx",

    "libs.etcd_watch.etcd_watch_def",
    "libs.etcd_watch.etcd_watch_result",
    "libs.etcd_watch.etcd_watcher",

    "libs.etcd_result.etcd_result_def",
    "libs.etcd_result.etcd_result",
    "libs.etcd_result.etcd_result_node",
    "libs.etcd_result.etcd_result_dir",
    "libs.etcd_result.etcd_result_node_visitor",

    "libs.proto_parser.proto_store_base",
    "libs.proto_parser.protobuf_store",
    "libs.proto_parser.sproto_store",
    "libs.proto_parser.proto_parser",

    "libs.mongo.mongo_def",
    "libs.mongo.mongo_client",
    "libs.mongo.mongo_options",

    "libs.redis.redis_def",
    "libs.redis.redis_client",
    "libs.redis.redis_reply",
    "libs.redis.redis_result",

    "libs.data_struct.random_hash",

    "servers.common.const.const",
    "servers.common.rpc.rpc",

    "servers.common.config.etcd_server_config",
    "servers.common.config.redis_server_config",
    "servers.common.config.mongo_server_config",

    "common.zone_service_mgr.zone_service_mgr_def",
    "common.zone_service_mgr.zone_service_mgr",
    "common.zone_service_mgr.zone_service_state",
    "common.zone_service_mgr.zone_service_mgr__peer_connect",
    "common.zone_service_mgr.zone_service_mgr__accept_connect",

    "common.msg_handler.msg_handler_base",
    "common.msg_handler.zone_service_msg_handler_base",
    "common.rpc.rpc_def",
    "common.rpc.rpc_mgr_base",
    "common.rpc.rpc_req",
    "common.rpc.rpc_rsp",
    "common.rpc.rpc_client",
    "common.rpc.zone_service.zone_service_rpc_mgr",

    "common.json_data",

    "common.init_global_vars",

    "servers.server_impl.server_def",
    "servers.server_impl.server_base",
    "servers.server_impl.server_base_property",

    "servers.services.service_def",
    "servers.services.service_base",
    "servers.services.service_mgr_base",
    "servers.services.hotfix_service",

    "libs.etcd_watch.etcd_watch_def",
    "libs.etcd_watch.etcd_watch_result",
    "libs.etcd_watch.etcd_watcher",

    "libs.etcd_result.etcd_result_def",
    "libs.etcd_result.etcd_result",
    "libs.etcd_result.etcd_result_node",
    "libs.etcd_result.etcd_result_dir",
    "libs.etcd_result.etcd_result_node_visitor",
}
return files