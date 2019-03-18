#pragma once

extern "C"
{
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}

#include "sol/sol.hpp"

extern int lua_panic_error(lua_State* L);
extern int lua_pcall_error(lua_State* L);
extern void StartLuaScript(lua_State *L, int begin_idx, int argc, char **argv);