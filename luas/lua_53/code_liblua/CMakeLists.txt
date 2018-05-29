CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

SET(ProjectName liblua)
PROJECT(${ProjectName})

SET(Cpp_File_Pattern "*.hpp" "*.cpp" "*.h" "*.c")
FileGlobRecurse(${PROJECT_SOURCE_DIR} "${Cpp_File_Pattern}" dir_files)
SET(SourceFiles ${SourceFiles} ${dir_files})
FileGroupByDir(${PROJECT_SOURCE_DIR} "${SourceFiles}" "")

INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR})

# Éú³É¿â
# include (${CMAKE_SOURCE_DIR}/cmake/AddLibarary.cmake)
ADD_LIBRARY(${ProjectName} SHARED ${SourceFiles})

IF (WIN32)
	
ELSE()

ENDIF (WIN32)





