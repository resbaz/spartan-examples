program hello
	implicit none 
        include "omp_lib.h"

	character(len=16) :: greetingsen
	character(len=16) :: greetingsde
	character(len=16) :: greetingsfr 
	integer :: a
	greetingsen = "Hello World!" 
	greetingsde = "Hallo Welt!"
	greetingsfr = "Bonjour le monde!"	

	!$omp parallel 
	!$omp sections

	!$omp section
	do a = 1, 100
	print *, greetingsen   
	end do

	!$omp section
	do a = 1, 100
	print *, greetingsde
	end do

	!$omp section
	do a = 1, 100
	print *, greetingsfr  
	end do

	!$omp end sections 
	!$omp end parallel
	
end program hello

