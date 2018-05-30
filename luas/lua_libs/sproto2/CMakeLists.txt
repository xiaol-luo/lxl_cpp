CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

SET(ProjectName sproto)
PROJECT(${ProjectName})

SET(Cpp_File_Pattern "*.hpp" "*.cpp" "*.h" "*.c")
FileGlobRecurse(${PROJECT_SOURCE_DIR} "${Cpp_File_Pattern}" dir_files)
SET(SourceFiles ${SourceFiles} ${dir_files})
FileGroupByDir(${PROJECT_SOURCE_DIR} "${SourceFiles}" "")

INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR})
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/luas/lua_53/code_liblua)
LINK_DIRECTORIES(${CMAKE_BINARY_DIR})
LINK_LIBRARIES(liblua)
ADD_DEFINITIONS(/D SPROTO_EXPORTS)

ADD_LIBRARY(${ProjectName} SHARED ${SourceFiles})

IF (WIN32)
	ADD_DEFINITIONS(/wd4018)
ELSE()

ENDIF (WIN32)

