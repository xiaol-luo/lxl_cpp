CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

SET(project_name pb)
PROJECT(${project_name})

SET(Cpp_File_Pattern "*.hpp" "*.cpp" "*.h" "*.c")
FileGlobRecurse(${PROJECT_SOURCE_DIR} "${Cpp_File_Pattern}" dir_files)
SET(all_files ${all_files} ${dir_files})
FileGroupByDir(${PROJECT_SOURCE_DIR} "${all_files}" "")

INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR})
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/lua53/lib)
LINK_LIBRARIES(lua53)

add_compile_options(-DLUA_BUILD_AS_DLL)
MakeLib(${project_name} "${all_files}" true)

IF (WIN32)
ELSE()
ENDIF (WIN32)

