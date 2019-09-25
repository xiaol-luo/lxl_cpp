#include <stdio.h>

// add_compile_options(-DTEST_DEF TEST_DEF_VAL_STR = Def_Val_STR TEST_DEF_VAL_INT = Def_Val_INT)

int main(int argc, char **argv)
{
	printf("hello world \n");

#ifdef TEST_DEF
	printf("TEST_DEF is Define"); 
#endif 

#ifdef TEST_DEF_VAL_STR
	printf("TEST_DEF_VAL_STR is %s\n", TEST_DEF_VAL_STR);
#endif

#ifdef TEST_DEF_VAL_INT
	printf("TEST_DEF_VAL_STR %d\n", TEST_DEF_VAL_INT);
#endif

#if TEST_DEF_VAL_INT == 10
	printf("TEST_DEF_VAL_INT is equal to %d \n", TEST_DEF_VAL_INT);
#endif

}
