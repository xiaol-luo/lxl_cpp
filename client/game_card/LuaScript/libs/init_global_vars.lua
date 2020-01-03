

base64 = require("libs.base64")
lua_json = require("libs.json")
rapidjson = require('rapidjson')

-- global sequence
gen_next_seq = make_sequence()

-- print("reach init global_vars", gen_next_seq())

--lua下谷歌的pb
pb = require("pb")
pb.option("use_default_metatable")
pb_protoc = require "libs.lua_protobuf.protoc"

--云风的pb
sproto = require "libs.sproto.sproto"
sproto_core = require "sproto.core"
sproto_parser = require("libs.sproto.sprotoparser")

