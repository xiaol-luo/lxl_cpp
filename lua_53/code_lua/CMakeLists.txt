CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

SET(ProjectName lua)
PROJECT(${ProjectName})

SET(Cpp_File_Pattern "*.hpp" "*.cpp" "*.h" "*.c")
FileGlobRecurse(${PROJECT_SOURCE_DIR} "${Cpp_File_Pattern}" dir_files)
SET(SourceFiles ${SourceFiles} ${dir_files})
FileGroupByDir(${PROJECT_SOURCE_DIR} "${SourceFiles}" "")

INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR})
INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/../code_liblua)
LINK_DIRECTORIES(${CMAKE_BINARY_DIR})
LINK_LIBRARIES(liblua)

ADD_EXECUTABLE(${ProjectName} ${SourceFiles})

IF (WIN32)

ELSE()
	LINK_LIBRARIES(m)
ENDIF (WIN32)




