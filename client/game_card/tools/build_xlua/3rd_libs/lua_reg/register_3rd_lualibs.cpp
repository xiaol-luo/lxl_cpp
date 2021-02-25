
#include "lua_reg.h"
#include <lua.hpp>

extern "C" {

LUALIB_API void register_3rd_lualibs(lua_State* L)
{
    register_native_libs(L);
}



}