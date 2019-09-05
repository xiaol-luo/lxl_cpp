cmake_minimum_required(VERSION 2.6)
SET(project_name r3c)
PROJECT(project_name})

SET(Cpp_File_Pattern "*.hpp" "*.cpp" "*.h" "*.c")
FileGlobRecurse(${PROJECT_SOURCE_DIR} "${Cpp_File_Pattern}" dir_files)
SET(all_files ${all_files} ${dir_files})
FileGroupByDir(${PROJECT_SOURCE_DIR} "${all_files}" "")

INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR})
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/third_party/hiredis)
LINK_LIBRARIES(hiredis)

if (NOT WIN32)
	add_definitions(-g -ggdb -fPIC -Wall -W -Wwrite-strings -Wno-missing-field-initializers -fstrict-aliasing)
else()
	ADD_COMPILE_OPTIONS(/wd4244 /wd4146 /wd4267 /wd4996 /wd4200 /wd4819)
endif()

MakeLib(${project_name} "${all_files}" false)

