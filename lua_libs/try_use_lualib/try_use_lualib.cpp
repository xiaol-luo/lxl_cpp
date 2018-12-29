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
static int do_openlib(lua_State *L)
{
	luaL_newlib(L, mylib);
	return 1;
}

static int other_log_msg(lua_State* L)
{
	printf("execute other_log_msg\n");
	return 0;
}
static const struct luaL_Reg other_mylib[] =
{
	{ "log_msg", other_log_msg },
	{ NULL, NULL }
};
static int other_do_openlib(lua_State *L)
{
	luaL_newlib(L, other_mylib);
	return 1;
}

int luaopen_tryuselualib(lua_State *L)
{
	printf("luaopen_tryuselualib\n");
	luaL_requiref(L, "tryuselualib", do_openlib, 1);
	luaL_requiref(L, "othertryuselualib", other_do_openlib, 1);
	return 0;
}
