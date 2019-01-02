extern "C" 
{
	#include "lua.h"
	#include "lauxlib.h"
	#include "lualib.h"
}

#define EXIT_FAILURE -1
#define EXIT_SUCCESS 0
#define LUA_SCRIPT_IDX 1

static int lua_status_report(lua_State *L, int status) 
{
	if (status != LUA_OK) {
		const char *msg = lua_tostring(L, -1);
		printf(msg);
		lua_pop(L, 1);  /* remove message */
	}
	return status;
}

static int lua_error_handler(lua_State *L) {
	const char *msg = lua_tostring(L, 1);
	if (msg == NULL) {  /* is error object not a string? */
		if (luaL_callmeta(L, 1, "__tostring") &&  /* does it have a metamethod */
			lua_type(L, -1) == LUA_TSTRING)  /* that produces a string? */
			return 1;  /* that is the message */
		else
			msg = lua_pushfstring(L, "(error object is a %s value)",
				luaL_typename(L, 1));
	}
	luaL_traceback(L, L, msg, 1);  /* append a standard traceback */
	return 1;  /* return the traceback */
}

int main (int argc, char **argv) 
{
  lua_State *L = luaL_newstate();  /* create state */
  if (L == NULL) {
    printf("cannot create state: not enough memory");
    return EXIT_FAILURE;
  }

  luaL_openlibs(L);
  lua_newtable(L);

  int top = lua_gettop(L);
  int status = LUA_OK;
  do 
  {
	  for (int i = LUA_SCRIPT_IDX + 1; i < argc; i++) {
		  lua_pushstring(L, argv[i]);
		  lua_rawseti(L, -2, i - LUA_SCRIPT_IDX);
		  printf("argv[%d]=%s\n", i, argv[i]);
	  }
	  lua_setglobal(L, "arg");
	  char *lua_file = argv[LUA_SCRIPT_IDX];
	  int status = luaL_loadfile(L, lua_file);
	  if (LUA_OK != status)
	  {
		  lua_status_report(L, status);
		  break;
	  }
	  int base = lua_gettop(L);
	  lua_pushcfunction(L, lua_error_handler);
	  lua_insert(L, base);
	  status = lua_pcall(L, 0, LUA_MULTRET, base);
	  lua_remove(L, base);

	  if (LUA_OK != status)
	  {
		  printf("%s", lua_tostring(L, -1));
		  break;
	  }
  } while (false);

  lua_settop(L, top);
  lua_close(L);
  return status;
}

