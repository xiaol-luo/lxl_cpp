#ifndef __LPEG_EXPORT_H__
#define __LPEG_EXPORT_H__

#ifdef __GNUC__
	#define LPEG_API 
#else
	#ifdef LPEG_EXPORTS  
		#define LPEG_API extern __declspec(dllexport)  
	#else  
		#define LPEG_API extern __declspec(dllimport)  
	#endif
#endif  

#include "lua.h"
LPEG_API int luaopen_lpeg(lua_State *L);

#endif
