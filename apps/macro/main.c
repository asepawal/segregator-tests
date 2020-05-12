#include <stdio.h>

#define SET1 __attribute__((section(".memset1")))
#define SET0 __attribute__((section(".memset0")))

SET0 int foo1(){
	return 8;
}

SET1 int foo2(){
	return 4;
}

SET0 int bar(){
	return foo1() + foo2();
}

int main(){
	printf("%d\n",bar());
}
