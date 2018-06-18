       program colourless
        implicit none 
	include "omp_lib.h"
	!$omp parallel
          print *, "Colourless " 
	  print *, "green "
	  print *, "ideas "
	  print *, "sleep furiously "
	!$omp end parallel
	  print *, ""
       end program colourless
