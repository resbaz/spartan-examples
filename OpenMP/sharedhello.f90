program SharedHello
implicit none
        character(len=16) :: greetings 
        greetings = "Hello World!" 
        print *, "Before parallel section: ", greetings 

        !$omp parallel num_threads(4) private(greetings)
        greetings = "Saluton mondo!"
        print *, "Inside parallel section: ", greetings
        !$omp end parallel

        print *, "After parallel section:  ", greetings

end program SharedHello
