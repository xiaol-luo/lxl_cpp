cmake_minimum_required(VERSION 2.6)

PROJECT(lxl_cpp)

option(address "hello world" ON)
set(OPT2 "Default" CACHE STRING "Helpstring")

include (${CMAKE_SOURCE_DIR}/cmake/AllInclude.cmake)
MESSAGE(STATUS ${CMAKE_BINARY_DIR})
MESSAGE(STATUS ${CMAKE_SOURCE_DIR})

INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR})
LINK_DIRECTORIES(${CMAKE_BINARY_DIR})

ADD_SUBDIRECTORY(lua_53)
ADD_SUBDIRECTORY(lua_libs)




