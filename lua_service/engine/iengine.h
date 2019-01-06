
#pragma once

#if defined(WIN32)
	#if defined(ENGINE_BUILD_AS_DLL)
		#define ENGINE_API __declspec(dllexport)
	#else
		#define ENGINE_API __declspec(dllimport)
	#endif
#else
	#define ENGINE_API extern
#endif

