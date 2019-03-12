#pragma once

extern "C"
{
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}
#include <sol/sol.hpp>
#include <string>
#include <unordered_map>
#include <functional>

#define TB_NATIVE "native"

sol::table get_or_create_table(lua_State *L, std::string tb_name);
void register_native_libs(lua_State *L);
void lua_reg_net(lua_State *L);
void lua_reg_make_shared_ptr(lua_State *L);
void lua_reg_mongo(lua_State *L);
bool lua_table_to_unorder_map(sol::table tb, std::unordered_map<std::string, std::string> &uo_map);
bool lua_object_to_string(sol::object lua_obj, std::string &out_str);

