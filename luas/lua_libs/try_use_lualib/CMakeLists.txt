CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

SET(ProjectName tryuselualib)
PROJECT(${ProjectName})

SET(Cpp_File_Pattern "*.hpp" "*.cpp" "*.h" "*.c")
FileGlobRecurse(${PROJECT_SOURCE_DIR} "${Cpp_File_Pattern}" dir_files)
SET(SourceFiles ${SourceFiles} ${dir_files})
FileGroupByDir(${PROJECT_SOURCE_DIR} "${SourceFiles}" "")

INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR})
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/luas/lua_53/code_liblua)
LINK_DIRECTORIES(${CMAKE_BINARY_DIR})

LINK_LIBRARIES(liblua)

# 生成库
# include (${CMAKE_SOURCE_DIR}/cmake/AddLibarary.cmake)
ADD_LIBRARY(${ProjectName} SHARED ${SourceFiles})

# 指定动态库版本
# VERSION 动态库版本
# SOVERSION API版本
#set_target_properties(person PROPERTIES VERSION 1.0 SOVERSION 1)

ADD_DEFINITIONS(/D TRY_USE_LUALIB_EXPORTS)

IF (WIN32)
	
ELSE()

ENDIF (WIN32)





