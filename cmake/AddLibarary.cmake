
SET(is_gen_dynamic_lib TRUE) #控制是否产生动态库
ADD_LIBRARY(${ProjectName} STATIC ${SourceFiles})
if (is_gen_dynamic_lib)
	ADD_LIBRARY(${ProjectName}_dynamic SHARED ${SourceFiles})
	# 指定动态库的输出名称
	SET_TARGET_PROPERTIES (${ProjectName}_dynamic PROPERTIES OUTPUT_NAME "${ProjectName}")
	# 使动态库和静态库同时存在
	SET_TARGET_PROPERTIES (${ProjectName} PROPERTIES CLEAN_DIRECT_OUTPUT 1)
	SET_TARGET_PROPERTIES (${ProjectName}_dynamic PROPERTIES CLEAN_DIRECT_OUTPUT 1)
ENDIF (is_gen_dynamic_lib)