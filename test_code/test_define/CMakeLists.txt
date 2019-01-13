CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

SET(project_name test_define)
PROJECT(${project_name})

SET(Cpp_File_Pattern "*.hpp" "*.cpp" "*.h" "*.c")
FileGlobRecurse(${PROJECT_SOURCE_DIR} "${Cpp_File_Pattern}" dir_files)
SET(all_files ${all_files} ${dir_files})
FileGroupByDir(${PROJECT_SOURCE_DIR} "${all_files}" "")

ADD_EXECUTABLE(${project_name} ${all_files})

add_compile_options(-DTEST_DEF TEST_DEF_VAL_STR="Def_Val_STR" TEST_DEF_VAL_INT=10) 

IF (WIN32)

ELSE()
	LINK_LIBRARIES(${project_name} m)
ENDIF (WIN32)




