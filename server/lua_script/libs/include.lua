
return
{
	{
        -- dir = ".",
        files =
        {
			"assert",
			"base64",
			"class",
			"date_time",
			"error_handler",
			"functional",
			"hotfix",
			"json",
			"json_data",
			"log",
			"msgpack",
			"path_ext",
			"random",
			"sequencer",
			"sha",
			"string_ext",
			"table_ext",
			"type_check",

        },
        includes =
        {
			"event.include",
			"consistent_hash.include",
			"coroutine_ex.include",
			"data_struct.include",
			"etcd.include",
			"etcd_result.include",
			"etcd_watch.include",
			"http.include",
			"lua_protobuf.include",
			"mongo.include",
			"net.include",
			"proto_parser.include",
			"redis.include",
			"rpc.include",
			"sproto.include",
			"timer.include",
			"try_use_lualibs.include",
			"xml2lua.include",
        },
    },
}