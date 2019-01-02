extern "C" 
{
	#include "lua.h"
	#include "lauxlib.h"
	#include "lualib.h"
}

#define EXIT_FAILURE -1
#define EXIT_SUCCESS 0
#define LUA_SCRIPT_IDX 1

int main (int argc, char **argv) 
{
  lua_State *L = luaL_newstate();  /* create state */
  if (L == NULL) {
    printf("cannot create state: not enough memory");
    return EXIT_FAILURE;
  }

  luaL_openlibs(L);
  lua_newtable(L);

  for (int i = LUA_SCRIPT_IDX + 1; i < argc; i++) {
	  lua_pushstring(L, argv[i]);
	  lua_rawseti(L, -2, i - LUA_SCRIPT_IDX);
  }
  lua_setglobal(L, "arg");
  char *lua_file = argv[LUA_SCRIPT_IDX];
  int ret = luaL_dofile(L, lua_file);
  if (LUA_OK != ret)
  {
	  printf("error is %s", lua_tostring(L, -1));
  }
  return ret;
}

