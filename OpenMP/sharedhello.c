#include <stdio.h>
#include  "omp.h"
int main(void)
{
	char greetings[] = "Hello world"; 
	printf("Before parallel section %s\n", greetings); 

	#pragma omp parallel num_threads(4) private(greetings)
	{
	char greetings[] = "Saluton mondo"; 
	printf("Inside parallel section %s\n", greetings); 
	}
	printf("After parallel section %s\n", greetings); 
return 0;
}

