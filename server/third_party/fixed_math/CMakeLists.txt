CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

SET(project_name fixed_math)
PROJECT(${project_name})

SET(Cpp_File_Pattern "*.hpp" "*.cpp" "*.h" "*.c")
FileGlobRecurse(${PROJECT_SOURCE_DIR} "${Cpp_File_Pattern}" dir_files)
SET(all_files ${all_files} ${dir_files})
FileGroupByDir(${PROJECT_SOURCE_DIR} "${all_files}" "")

INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR})


IF (WIN32)
	ADD_DEFINITIONS(-D_WINSOCK_DEPRECATED_NO_WARNINGS)
	ADD_DEFINITIONS(-DBOOST_NO_CXX17_HDR_STRING_VIEW)
ELSE()
	LINK_LIBRARIES(m)
ENDIF (WIN32)

MakeLib(${project_name} "${all_files}" false)

