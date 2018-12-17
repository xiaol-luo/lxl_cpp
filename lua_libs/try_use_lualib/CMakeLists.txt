CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

SET(project_name try_use_lualib)
PROJECT(${project_name})

SET(Cpp_File_Pattern "*.hpp" "*.cpp" "*.h" "*.c")
FileGlobRecurse(${PROJECT_SOURCE_DIR} "${Cpp_File_Pattern}" dir_files)
SET(all_files ${all_files} ${dir_files})
FileGroupByDir(${PROJECT_SOURCE_DIR} "${all_files}" "")

INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR})
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/lua53/lib)
LINK_LIBRARIES(lua53)
ADD_COMPILE_DEFINITIONS(BUILD_AS_DLL)

# Éú³É¶¯Ì¬¿â
SET(lib_name ${project_name})
ADD_LIBRARY(${lib_name} SHARED ${all_files})
INCLUDE(${CMAKE_SOURCE_DIR}/cmake/StaticLib.cmake)

IF (WIN32)
ELSE()
ENDIF (WIN32)






