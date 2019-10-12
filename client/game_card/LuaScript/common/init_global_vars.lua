

base64 = require("libs.base64")
lua_json = require("libs.json")
rapidjson = require('rapidjson')

-- global sequence
gen_next_seq = make_sequence()

-- print("reach init global_vars", gen_next_seq())