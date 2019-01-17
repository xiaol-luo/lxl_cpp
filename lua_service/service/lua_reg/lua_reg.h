#pragma once

extern "C"
{
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}
#include <sol/sol.hpp>

#define TB_NATIVE "native"

sol::table get_or_create_table(lua_State *L, std::string tb_name);
void lua_reg_net(lua_State *L);
void register_native_libs(lua_State *L);
void lua_reg_make_shared_ptr(lua_State *L);