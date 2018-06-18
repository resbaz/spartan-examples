        program particle_advector

          implicit none

          include 'mpif.h'

          real, parameter       :: movementSpeedDivisor = 3
          integer, parameter    :: movementSign = 1
          real, parameter, dimension(2) :: attractorPoint = 0.0

          integer               :: numTimeSteps = 10
          integer               :: timeStep_I = 0
          integer               :: globalParticlesCount = 50
          integer               :: localParticlesCount
          integer               :: gParticle_I, lParticle_I

          integer, dimension(:), allocatable :: globalIds
          integer, dimension(:), allocatable :: globalTags
          real, dimension(:), allocatable    :: globalXCoords
          real, dimension(:), allocatable    :: globalYCoords

          integer, dimension(:), allocatable :: localIds
          integer, dimension(:), allocatable :: localTags
          real, dimension(:), allocatable    :: localXCoords
          real, dimension(:), allocatable    :: localYCoords

          integer       :: seed
          real          :: closestDistance
          integer       :: closestParticleId
          real          :: distance, distFromAttractor

          integer       :: myRank=0, nProc=0, ierr

          integer, parameter :: bigNum = 1000000
          integer            :: randXCoord,randYCoord
          real               :: randNumX, randNumY

          call MPI_INIT(ierr)
          call MPI_COMM_RANK( MPI_COMM_WORLD, myRank, ierr )
          call MPI_COMM_SIZE( MPI_COMM_WORLD, nProc, ierr )

          if( myRank .eq. 0 ) then
            allocate( globalIds(globalParticlesCount), &
            &         globalTags(globalParticlesCount), &
            &         globalXCoords(globalParticlesCount), &
            &         globalYCoords(globalParticlesCount),stat=ierr)

            ! mpif77/90 doesn't seem to allow I/O (at least not of the above format), 
            ! hard code seed instead
            seed = 101
            call RANDOM_SEED( seed )

            ! initialise particle properties
            do gParticle_I = 1, globalParticlesCount
              globalIds(gParticle_I) = gParticle_I
              globalTags(gParticle_I) = MOD( gParticle_I, 10 )
              call RANDOM_NUMBER( randNumX )
              randXCoord = bigNum * randNumX
              globalXCoords(gParticle_I) = 5.0 +  &
              &   1.0 * MOD( randXCoord, 1000 ) / 200
              call RANDOM_NUMBER( randNumY )
              randYCoord = bigNum * randNumY
              globalYCoords(gParticle_I) = 5.0 + &
              &   1.0 * MOD( randYCoord, 1000 ) / 200
            end do

          end if

          ! TODO calculate how may particles per processor and modify
          ! the lines below accordingly 

          localParticlesCount = globalParticlesCount
          allocate( localIds(localParticlesCount), &
          &         localTags(localParticlesCount), &
          &         localXCoords(localParticlesCount), &
          &         localYCoords(localParticlesCount), stat=ierr )

          ! TODO distribute globalParticles arrays between processor, into each
          ! processor's localParticles arrays 

          ! TODO : advanced 3: use scatterv to work with any number of
          ! processors

          do timeStep_I = 1, numTimeSteps
            closestDistance = 100000.0

            do lParticle_I = 1, localParticlesCount
              call updatePartToAttr( localXCoords(lParticle_I), &
              &       localYCoords(lParticle_I), attractorPoint, &
              &       movementSpeedDivisor, movementSign )

              ! record if particle is closest, and if so what distance is
              distance = distFromAttractor( localXCoords(lParticle_I),&
              &                             localYCoords(lParticle_I),&
              &                             attractorPoint ) 

              if( distance .lt. closestDistance ) then
                closestDistance = distance
                closestParticleId = localIds(lParticle_I)
              end if
            end do
 
            print*, myRank, ': After timestep', timeStep_I, &
            &       'closest particle is', closestParticleId, &
            &       ', at distance', closestDistance 

            ! TODO advanced 1: if processor 0, calculate a global minimum
            ! TODO advanced 2: if closest global particle < 0, then flip
            ! particles to move away from now on

          end do

          if( myRank .eq. 0 ) then
            deallocate( globalIds, globalTags, globalXCoords, &
            &           globalYCoords )
          end if  

          deallocate( localIds, localTags, localXCoords, localYCoords )

          call MPI_FINALIZE(ierr)

        end program

        subroutine updatePartToAttr( xCoord, yCoord, attractorPoint, &
        &                            movementSpeedDivisor, &
        &                            movementSign )

          implicit none

          real               :: xCoord,yCoord
          real, dimension(2) :: attractorPoint
          real               :: movementSpeedDivisor
          integer            :: movementSign

          real, dimension(2) :: movementVector
          integer            :: dim_I

          movementVector(1) = (attractorPoint(1) - xCoord) / &
          &                   movementSpeedDivisor
          movementVector(2) = (attractorPoint(2) - yCoord) / &
          &                   movementSpeedDivisor

          do dim_I = 1, 2
            movementVector(dim_I) = movementVector(dim_I) * &
            &                       movementSign
          end do

          xCoord = xCoord + movementVector(1)
          yCoord = yCoord + movementVector(2)

        end subroutine

        real function distFromAttractor( xCoord, yCoord, &
        &                                attractorPoint )

          implicit none

          real               :: xCoord, yCoord
          real, dimension(2) :: attractorPoint

          real, dimension(2) :: differenceVector

          differenceVector(1) = attractorPoint(1) - xCoord
          differenceVector(2) = attractorPoint(2) - yCoord

          distFromAttractor = SQRT( differenceVector(1) * &
          &                         differenceVector(1) + &
          &                         differenceVector(2) * &
          &                         differenceVector(2) )

        end function



