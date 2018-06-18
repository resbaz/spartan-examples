      program sendrecv
      include "mpif.h"
      integer myid, ierr,numprocs
      integer tag,source,destination,count
      integer buffer
      integer status(MPI_STATUS_SIZE)
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      tag=1
      source=0
      destination=1
      count=1
      if(myid .eq. source)then
         print*, 'I am the root 0 process of the group (total', &
         &  numprocs, ').'
         buffer=1729
         Call MPI_Send(buffer, count, MPI_INTEGER,destination,&
          tag, MPI_COMM_WORLD, ierr)
         write(*,*)"processor ",myid," sent ",buffer
      endif
      if(myid .eq. destination)then
         print*, 'I am a subsidiary process', rank, &
          &  ' of the group (total ', numProcs, ').'
         Call MPI_Recv(buffer, count, MPI_INTEGER,source,&
          tag, MPI_COMM_WORLD, status,ierr)
         write(*,*)"processor ",myid," received ",buffer
      endif
      call MPI_FINALIZE(ierr)
      stop
      end
