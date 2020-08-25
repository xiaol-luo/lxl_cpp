
Const = {}

Const.role_count_per_user = 3

require("servers.common.const.const_main_args")
require("servers.common.const.const_server")
require("servers.common.const.const_mongo")

Http_OK = "OK"

Error_None = 0

MICRO_SEC_PER_SEC = 1000
SERVICE_FRAME_PER_SEC = 30
SERVICE_MICRO_SEC_PER_FRAME = MICRO_SEC_PER_SEC / SERVICE_FRAME_PER_SEC