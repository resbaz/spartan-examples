#include <stdio.h>
#include <stdlib.h>
#include "omp.h"

int main (void)
{
#pragma omp parallel
 { 
	printf("Colourless ");
	printf("green ");
	printf("ideas ");
	printf("sleep furiously ");
   }
 printf("\n");
 return(0);
}	
