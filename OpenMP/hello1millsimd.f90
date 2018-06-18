program hello
	implicit none 
        include "omp_lib.h"
	character(len=16) :: greetings 
	integer :: a
	greetings = "Hello World!" 

	! Hello World, one million times
	!$omp simd
	do a = 1, 1000000
	print *, greetings   
	end do

end program hello

