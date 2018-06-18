#include <stdio.h> 
#include  "omp.h"
int main(void) 
{ 
   char greetingsen[] = "Hello world!"; 
   char greetingsde[] = "Hallo Welt!";
   char greetingsfr[] = "Bonjour le monde!";
   int a;
   #pragma parallel 

   #pragma omp sections
   {
   #pragma omp section
   for ( a = 0; a < 100; a = a + 1 )
   	{
	printf("%s\n", greetingsen); 
   	}

   #pragma omp section
   for ( a = 0; a < 100; a = a + 1 )
   	{
	printf("%s\n", greetingsde); 
   	}

   #pragma omp section
   for ( a = 0; a < 100; a = a + 1 )
   	{
	printf("%s\n", greetingsfr); 
   	}
    }
return 0;
}
