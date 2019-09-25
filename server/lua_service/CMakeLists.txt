cmake_minimum_required(VERSION 2.6)

IF (WIN32)
	INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/third_party/win_mongo/include/libmongoc-1.0)
	INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/third_party/win_mongo/include/libbson-1.0)
	INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/third_party/win_mongo/include/mongocxx/v_noabi)
	INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/third_party/win_mongo/include/bsoncxx/v_noabi)
	INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/third_party)
	LINK_DIRECTORIES(${CMAKE_SOURCE_DIR}/third_party/win_mongo/lib)
	INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/third_party/win_protobuf/include)
	LINK_DIRECTORIES(${CMAKE_SOURCE_DIR}/third_party/win_protobuf/lib)
ELSE()
	LINK_LIBRARIES(m)
	LINK_LIBRARIES(pthread)
	INCLUDE_DIRECTORIES("/usr/local/include/bsoncxx/v_noabi")
	INCLUDE_DIRECTORIES("/usr/local/include/mongocxx/v_noabi")
ENDIF (WIN32)

ADD_SUBDIRECTORY(service)
ADD_SUBDIRECTORY(engine)




