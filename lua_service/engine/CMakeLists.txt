CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

SET(project_name engine)
PROJECT(project_name})

SET(Cpp_File_Pattern "*.hpp" "*.cpp" "*.h" "*.c")
FileGlobRecurse(${PROJECT_SOURCE_DIR} "${Cpp_File_Pattern}" dir_files)
SET(all_files ${all_files} ${dir_files})
FileGroupByDir(${PROJECT_SOURCE_DIR} "${all_files}" "")

INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR})
INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/framework)
INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/libs)
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/lua53/lib)
LINK_LIBRARIES(lua53)
LINK_LIBRARIES(data_struct)


IF (WIN32)
	ADD_DEFINITIONS(-D_WINSOCK_DEPRECATED_NO_WARNINGS)
ELSE()
	LINK_LIBRARIES(m)
	LINK_LIBRARIES(pthread)
ENDIF (WIN32)

MakeLib(${project_name} "${all_files}" false)

