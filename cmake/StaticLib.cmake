IF (WIN32)
	# 生成静态库
	SET(static_lib_subfix "static")
	SET(static_lib_name ${lib_name}${static_lib_subfix})
	ADD_LIBRARY(${static_lib_name} STATIC ${all_files})
	# 指定动态库的输出名称
	SET_TARGET_PROPERTIES (${static_lib_name} PROPERTIES OUTPUT_NAME "${lib_name}")
	# 使动态库和静态库同时存在
	SET_TARGET_PROPERTIES (${lib_name} PROPERTIES CLEAN_DIRECT_OUTPUT 1)
	SET_TARGET_PROPERTIES (${static_lib_name} PROPERTIES CLEAN_DIRECT_OUTPUT 1)
ENDIF()