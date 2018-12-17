#pragma once

#ifdef __GNUC__
	#define Dll_API extern "C" 
#else
	#ifdef BUILD_AS_DLL  
		#define Dll_API extern "C" __declspec(dllexport)  
	#else  
		#define Dll_API extern "C" __declspec(dllimport)  
	#endif
#endif  

extern "C" {
	#include <lua.h>
	#include <lualib.h>
	#include <lauxlib.h>
}

Dll_API int luaopen_tryuselualib(lua_State *L);
