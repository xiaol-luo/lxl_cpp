CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

SET(ProjectName luac)
PROJECT(${ProjectName})

SET(Cpp_File_Pattern "*.hpp" "*.cpp" "*.h" "*.c")
FileGlobRecurse(${PROJECT_SOURCE_DIR} "${Cpp_File_Pattern}" dir_files)
SET(SourceFiles ${SourceFiles} ${dir_files})
FileGroupByDir(${PROJECT_SOURCE_DIR} "${dir_files}" "")

FileGlobRecurse(${PROJECT_SOURCE_DIR}/../code_liblua "${Cpp_File_Pattern}" dir_files)
SET(SourceFiles ${SourceFiles} ${dir_files})
FileGroupByDir(${PROJECT_SOURCE_DIR}/../code_liblua "${dir_files}" "")



INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR})
INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/../code_liblua)

ADD_EXECUTABLE(${ProjectName} ${SourceFiles})

IF (WIN32)
	
ELSE()
	LINK_LIBRARIES(m)
ENDIF (WIN32)




