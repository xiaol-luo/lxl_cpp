
# cmake ../../git_code/lxl_cpp/ -DXXX=ABCD -DCMAKE_BUILD_TYPE=Debug
# cmake ../../git_code/lxl_cpp/ -DXXX=ABCD -DCMAKE_BUILD_TYPE=Release

MESSAGE(STATUS "-------------------- test_cmake_opt_D.cmake --------------------")

IF (${CMAKE_BUILD_TYPE} STREQUAL "Debug")
	MESSAGE(STATUS "This is Debug " ${CMAKE_BUILD_TYPE})
ELSE()
	MESSAGE(STATUS "This is Release " ${CMAKE_BUILD_TYPE})
ENDIF()

MESSAGE(STATUS "cmake option -DXXX=ABCD makes \${XXX}=" ${XXX})
