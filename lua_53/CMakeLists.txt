cmake_minimum_required(VERSION 2.6)

PROJECT(lua)

ADD_DEFINITIONS(/D LUA_BUILD_AS_DLL)

ADD_SUBDIRECTORY(code_liblua)
ADD_SUBDIRECTORY(code_lua)
# ADD_SUBDIRECTORY(code_luac)




