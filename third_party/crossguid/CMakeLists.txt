cmake_minimum_required(VERSION 3.5.1)
project(CrossGuid)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/cmake")

message(status "xxxxxxxxxxxxxxxxxxxxxxx ${PROJECT_SOURCE_DIR}/cmake")

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)

# Set the build type if not set
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug")
endif()

add_library(crossguid ${CMAKE_CURRENT_SOURCE_DIR}/crossguid/guid.cpp ${CMAKE_CURRENT_SOURCE_DIR}/crossguid/guid.hpp)
set_property(TARGET crossguid PROPERTY POSITION_INDEPENDENT_CODE ON)
target_include_directories(crossguid PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)

if(WIN32)
    target_compile_definitions(crossguid PRIVATE GUID_WINDOWS)
elseif(APPLE)
    find_library(CFLIB CoreFoundation)
    target_link_libraries(crossguid ${CFLIB})
    target_compile_definitions(crossguid PRIVATE GUID_CFUUID)
elseif(ANDROID)
    # GUID_ANDROID is used in the headers, so make PUBLIC
    target_compile_definitions(crossguid PUBLIC GUID_ANDROID)
else()
    find_package(Libuuid REQUIRED)
    if (NOT LIBUUID_FOUND)
        message(FATAL_ERROR
            "You might need to run 'sudo apt-get install uuid-dev' or similar")
    endif()
    target_include_directories(crossguid PRIVATE ${LIBUUID_INCLUDE_DIR})
    target_link_libraries(crossguid ${LIBUUID_LIBRARY})
    target_compile_definitions(crossguid PRIVATE GUID_LIBUUID)
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    set(WARNINGS "-Werror" "-Wall")
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(WARNINGS "-Werror" "-Wall")
elseif(MSVC)
    set(WARNINGS "/WX" "/W4")
endif()
target_compile_options(crossguid PRIVATE ${WARNINGS})

