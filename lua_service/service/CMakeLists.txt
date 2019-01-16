CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

SET(project_name service)
PROJECT(project_name})

SET(Cpp_File_Pattern "*.hpp" "*.cpp" "*.h" "*.c")
FileGlobRecurse(${PROJECT_SOURCE_DIR} "${Cpp_File_Pattern}" dir_files)
SET(all_files ${all_files} ${dir_files})
FileGroupByDir(${PROJECT_SOURCE_DIR} "${all_files}" "")

INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR})
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/lua53/lib)
LINK_LIBRARIES(lua53)
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/lua_service/engine)
LINK_LIBRARIES(engine)

IF (WIN32)
	LINK_LIBRARIES(ws2_32)
ELSE()
	LINK_LIBRARIES(m)
ENDIF (WIN32)

ADD_EXECUTABLE(${project_name} ${all_files})

