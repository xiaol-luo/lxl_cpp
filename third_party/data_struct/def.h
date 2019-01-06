#pragma once

#if defined(WIN32)
#if defined(DATA_STRUCT_BUILD_AS_DLL)
#define DATA_STRUCT_API __declspec(dllexport)
#else
#define DATA_STRUCT_API __declspec(dllimport)
#endif
#else
#define DATA_STRUCT_API extern
#endif

