#include "try_use_lualib.h"
#include <stdio.h>

static int log_msg(lua_State* L)
{
	printf("execute log_msg\n");
	return 0;
}

static const struct luaL_Reg mylib[] =
{
	{ "log_msg", log_msg },
	{ NULL, NULL }
};

int luaopen_tryuselualib(lua_State *L)
{
	luaL_newlib(L, mylib);
	return 1;
}
