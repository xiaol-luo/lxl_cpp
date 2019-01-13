CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

SET(project_name lua53)
PROJECT(${project_name})

INCLUDE (${CMAKE_SOURCE_DIR}/cmake/Utils.cmake)
SET(Cpp_File_Pattern "*.hpp" "*.cpp" "*.h" "*.c")
FileGlobRecurse(${PROJECT_SOURCE_DIR} "${Cpp_File_Pattern}" dir_files)
SET(all_files ${all_files} ${dir_files})
FileGroupByDir(${PROJECT_SOURCE_DIR} "${all_files}" "")

INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR})
add_compile_options(-DLUA_BUILD_AS_DLL)
MakeLib(${project_name} "${all_files}" true)





