MESSAGE(STATUS "-------------------- test_macro.cmake --------------------")

MACRO(test_macro p1 p2 p3)
	MESSAGE(STATUS "NOT WRAP " p1 " " p2 " " p3)
	MESSAGE(STATUS "WRAP " "${p1} ${p2} ${p3}")
ENDMACRO(test_macro)

SET(a "hello")
SET(b "world")
SET(c "d")
SET(d "this is d")
test_macro(a b c)
MESSAGE(STATUS "-------")
test_macro(${a} ${b} ${c})
