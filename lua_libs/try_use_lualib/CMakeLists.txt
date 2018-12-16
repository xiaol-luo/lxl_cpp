CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

SET(project_name try_use_lualib)
PROJECT(${project_name})

SET(Cpp_File_Pattern "*.hpp" "*.cpp" "*.h" "*.c")
FileGlobRecurse(${PROJECT_SOURCE_DIR} "${Cpp_File_Pattern}" dir_files)
SET(all_files ${all_files} ${dir_files})
FileGroupByDir(${PROJECT_SOURCE_DIR} "${all_files}" "")

INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR})
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/lua53/lib)
LINK_LIBRARIES(lualib53${dyn_lib_subfix})
ADD_COMPILE_DEFINITIONS(TRY_USE_LUALIB_EXPORTS)

# 生成静态库
SET(static_lib_name ${project_name})
ADD_LIBRARY(${static_lib_name} STATIC ${all_files})
IF (use_dyn_lib)
	#生成动态库
	SET(dyn_lib_name ${static_lib_name}${dyn_lib_subfix})
	ADD_LIBRARY(${dyn_lib_name} SHARED ${all_files})
	IF (WIN32)
		# 指定动态库的输出名称
		SET_TARGET_PROPERTIES (${dyn_lib_name} PROPERTIES OUTPUT_NAME "${static_lib_name}")
		# 使动态库和静态库同时存在
		SET_TARGET_PROPERTIES (${static_lib_name} PROPERTIES CLEAN_DIRECT_OUTPUT 1)
		SET_TARGET_PROPERTIES (${dyn_lib_name} PROPERTIES CLEAN_DIRECT_OUTPUT 1)
	ENDIF (WIN32)
ENDIF(use_dyn_lib)

IF (WIN32)
ELSE()
ENDIF (WIN32)






