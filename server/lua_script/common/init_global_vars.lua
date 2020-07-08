
Functional.error_handler = error_handler

rapidjson = require('rapidjson')

-- lua下序列化反序列化工具
serpent = require("libs.serpent")

--云风的pb
sproto = require "libs.sproto.sproto"
sproto_core = require "sproto.core"
sproto_parser = require("libs.sproto.sprotoparser")

--lua下谷歌的pb
pb = require("pb")
pb_protoc = require "libs.lua_protobuf.protoc"

-- base64
Base64 = require("libs.base64")

-- global sequence

gen_next_seq = make_sequence()

-- https://github.com/rxi/json.lua
-- A lightweight JSON library for Lua
lua_json = require("libs.json")

msgpack = require("libs.msgpack")

local sha = require("libs.sha")
hash256 = sha.hash256
new_hash256 = sha.new256

gen_uuid = native.gen_uuid
