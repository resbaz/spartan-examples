       program colourless
	include "omp_lib.h"
	!$omp parallel
	 !$omp single
	  print *, "Noam Chomsky said "
	  !omp task
          print *, "Colourless " 
	  !omp end task
	  !omp task
	  print *, "green "   
	  !omp end task
	  !omp task
	  print *, "ideas "  
          !omp end task
	  print *, "sleep furiously "
	 !$omp end single
	!$omp end parallel
       end program colourless
