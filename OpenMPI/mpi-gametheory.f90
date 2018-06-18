        program mainFunction 

          implicit none

          include 'mpif.h'
          ! player A is first entry in arrays
          ! player B is second entry
	  real, dimension(2)   :: probCoopIfOppComp
          real, dimension(2)   :: probCoopIfOppCoop
	  logical,dimension(2) :: oppCoopLastMove
 
          integer, parameter :: playerAIndex=1
          integer, parameter :: playerBIndex=2
          integer, parameter :: totalRounds=100

	  real          :: playerA_Sum, playerB_Sum
          integer, dimension(2,100) :: randomPercentages(2, 100)
          real, dimension(2)        :: payoffResults
          logical, dimension(2)     :: playerCoops

	  logical       :: playerDec
          integer       :: round_I
          integer       :: thisPlayerIndex, otherPlayerIndex
          
          integer       :: rq
          integer       :: st(MPI_STATUS_SIZE)
          integer       :: rank, ierr

          call MPI_INIT( ierr )
          call MPI_COMM_RANK( MPI_COMM_WORLD, rank, ierr )

          round_I = 0
          playerA_Sum = 0
          playerB_Sum = 0
          
          ! create the players 
          if( rank .eq. 0 ) then 
          ! Make player A "nice"
            probCoopIfOppComp(playerAIndex) = 0.5
            probCoopIfOppCoop(playerAIndex) = 1
            playerCoops(playerAIndex) = .True.
            oppCoopLastMove(playerAIndex) = .True.

            thisPlayerIndex = playerAIndex
            otherPlayerIndex = playerBIndex
          else 
          ! Make player B "sneaky" 
            probCoopIfOppComp(playerBIndex) = 0.25
            probCoopIfOppCoop(playerBIndex) = 0.7
            playerCoops(playerBIndex) = .True.
            oppCoopLastMove(playerBIndex) = .True.

            thisPlayerIndex = playerBIndex
            otherPlayerIndex = playerAIndex
          end if

          ! Pre-Generate the percentages for each round, in order to be repeatable 
          call SRAND( 1 )
          do round_I = 0, totalRounds-1
            randomPercentages(playerAIndex, round_I) = rand() * 100
            randomPercentages(playerBIndex, round_I) = rand() * 100
          end do
         
          do round_I = 0, totalRounds-1
            ! query this player decision
            playerCoops(thisPlayerIndex) = &
            &    playerDec(oppCoopLastMove(thisPlayerIndex), &
            &    probCoopIfOppCoop(thisPlayerIndex), &
            &    probCoopIfOppComp(thisPlayerIndex), &
            &    randomPercentages(thisPlayerIndex, round_I) )

            call MPI_IRECV( playerCoops(otherPlayerIndex), 1, &
            &               MPI_LOGICAL, otherPlayerIndex-1, 0, &
            &               MPI_COMM_WORLD, rq, ierr  )
            call MPI_SEND( playerCoops(thisPlayerIndex), 1, &
            &              MPI_LOGICAL, otherPlayerIndex-1, 0, &
            &              MPI_COMM_WORLD, ierr )
            call MPI_WAIT( rq, st, ierr )
            
            ! inform this player of other player's decision
            oppCoopLastMove(thisPlayerIndex) = playerCoops(otherPlayerIndex)

            ! Calculate the payoffs 
            call calculatePayoffs( playerCoops, payoffResults )

            ! update the sums 
            playerA_Sum = playerA_Sum + payoffResults(playerAIndex)
            playerB_Sum = playerB_Sum + payoffResults(playerBIndex)
          end do

          print*, rank, "After ",totalRounds, &
          &       " rounds, player A has earnt $", &
          &       playerA_Sum,", player B has earnt $", playerB_Sum 

          call MPI_FINALIZE( ierr )

        end program

        subroutine calculatePayoffs( playerCoops, payoffResults )
          logical, dimension(2) :: playerCoops
          real, dimension(2)    :: payoffResults

          integer, parameter    :: playerAIndex=1
          integer, parameter    :: playerBIndex=2

          if( playerCoops(playerAIndex) .and. &
            & playerCoops(playerBIndex) ) then
            payoffResults(playerAIndex) = 2
            payoffResults(playerBIndex) = 2
          else if( (.not.playerCoops(playerAIndex)) .and. &
          &        (.not.playerCoops(playerBIndex))) then
            payoffResults(playerAIndex) = 1
            payoffResults(playerBIndex) = 1
          else if( (.not.playerCoops(playerAIndex)) .and. &
          &        playerCoops(playerBIndex)) then
            payoffResults(playerAIndex) = 3
            payoffResults(playerBIndex) = 0
          else if( playerCoops(playerAIndex) .and. &
          &        (.not.playerCoops(playerBIndex)) ) then
            payoffResults(playerAIndex) = 0
            payoffResults(playerBIndex) = 3
          end if
        end subroutine

	logical function playerDec(oppCoopLastMove,probCoopIfOppCoop, &
        &                          probCoopIfOppComp, randomPercentages) 
          real          :: probCoopIfOppCoop
          real          :: probCoopIfOppComp
          logical       :: oppCoopLastMove
          integer       :: randomNum 
          real          :: percentProbCoop
          integer       :: randomPercentages

          randomNum = randomPercentages

          if( oppCoopLastMove ) then
            percentProbCoop = ( 100 * (probCoopIfOppCoop) )
          else 
            percentProbCoop = ( 100 * (probCoopIfOppComp) )
          end if

          if( percentProbCoop  .ge. randomNum ) then
            playerDec = .TRUE.
          else 
            playerDec = .FALSE.
          end if

        end function


