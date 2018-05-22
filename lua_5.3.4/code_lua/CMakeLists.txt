CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

SET(ProjectName lua)
PROJECT(${ProjectName})

SET(Cpp_File_Pattern "*.hpp" "*.cpp" "*.h" "*.c")
FileGlobRecurse(${PROJECT_SOURCE_DIR} "${Cpp_File_Pattern}" dir_files)
SET(SourceFiles ${SourceFiles} ${dir_files})
FileGroupByDir(${PROJECT_SOURCE_DIR} "${SourceFiles}" "")

INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/../code_liblua)
LINK_DIRECTORIES(${CMAKE_BINARY_DIR})
LINK_LIBRARIES(liblua)

ADD_LIBRARY(${ProjectName} STATIC ${SourceFiles})
if (is_gen_dynamic_lib)
	ADD_LIBRARY(${ProjectName}_dynamic SHARED ${SourceFiles})
	# 指定动态库的输出名称
	SET_TARGET_PROPERTIES (${ProjectName}_dynamic PROPERTIES OUTPUT_NAME "${ProjectName}")
	# 使动态库和静态库同时存在
	SET_TARGET_PROPERTIES (${ProjectName} PROPERTIES CLEAN_DIRECT_OUTPUT 1)
	SET_TARGET_PROPERTIES (${ProjectName}_dynamic PROPERTIES CLEAN_DIRECT_OUTPUT 1)
ENDIF (is_gen_dynamic_lib)

IF (WIN32)
	ADD_DEFINITIONS(/D _CRT_SECURE_NO_WARNINGS /wd4267 /wd4244 /wd4996 /wd4800 /D _WINSOCK_DEPRECATED_NO_WARNINGS)
ELSE()
	LINK_LIBRARIES(m)
ENDIF (WIN32)




