       program hello
	!$omp parallel
          print *, "Hello world!"
	!$omp end parallel
       end program hello
