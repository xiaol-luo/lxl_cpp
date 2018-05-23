#pragma once

#ifdef __GNUC__
	#define TRY_USE_LUALIB_API extern "C" 
#else
	#ifdef TRY_USE_LUALIB_EXPORTS  
		#define TRY_USE_LUALIB_API extern "C" __declspec(dllexport)  
	#else  
		#define TRY_USE_LUALIB_API extern "C" __declspec(dllimport)  
	#endif
#endif  

extern "C" {
	#include <lua.h>
	#include <lualib.h>
	#include <lauxlib.h>
}

TRY_USE_LUALIB_API int luaopen_tryuselualib(lua_State *L);
