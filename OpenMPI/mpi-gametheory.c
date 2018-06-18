#include <stdlib.h>
#include <stdio.h>
#include <mpi.h>

typedef char Bool;
const char False = 0; 
const char True = 1; 

typedef struct Player {
	float   probOfCooperateIfOppoCompeted;
	float   probOfCooperateIfOppoCooperated;
	Bool    iCooperatedLastMove;
	Bool    oppoCooperatedLastMove;
} Player;

const unsigned int PLAYER_A_INDEX = 0;
const unsigned int PLAYER_B_INDEX = 1;

void calculatePayoffs( Bool playerCooperations[2], float payoffResults[2] ) {
	if ( playerCooperations[PLAYER_A_INDEX] && playerCooperations[PLAYER_B_INDEX] ) {
		payoffResults[PLAYER_A_INDEX] = 2;
		payoffResults[PLAYER_B_INDEX] = 2;
	}
	else if ( !playerCooperations[PLAYER_A_INDEX] && !playerCooperations[PLAYER_B_INDEX] ) {
		payoffResults[PLAYER_A_INDEX] = 1;
		payoffResults[PLAYER_B_INDEX] = 1;
	}
	else if ( !playerCooperations[PLAYER_A_INDEX] && playerCooperations[PLAYER_B_INDEX] ) {
		payoffResults[PLAYER_A_INDEX] = 3;
		payoffResults[PLAYER_B_INDEX] = 0;
	}
	else if ( playerCooperations[PLAYER_A_INDEX] && !playerCooperations[PLAYER_B_INDEX] ) {
		payoffResults[PLAYER_A_INDEX] = 0;
		payoffResults[PLAYER_B_INDEX] = 3;
	}
}

Bool player_GetDecision( Player* player, int randomPercent ) {
	float percentageProbCooperate;

	if ( player->oppoCooperatedLastMove ) {
		percentageProbCooperate = 100 * player->probOfCooperateIfOppoCooperated;
	}
	else {
		percentageProbCooperate = 100 * player->probOfCooperateIfOppoCompeted;
	}
	if ( randomPercent < percentageProbCooperate ) {
		return True;
	}
	else {
		return False;
	}
}


int main( int argc, char** argv ) {
	Player thisPlayer;
	float playerSums[2] = { 0, 0 };
	float payoffResults[2];
	Bool playerCooperations[2];
	int randomPercentages[2][100];
	int totalRounds = 100;
	unsigned int round_I = 0;
	int myRank = 0;
	unsigned int thisPlayerIndex = 0;
	unsigned int otherPlayerIndex = 0;
	MPI_Request request;
	MPI_Status recvStatus;

	MPI_Init( &argc, &argv );
	MPI_Comm_rank( MPI_COMM_WORLD, &myRank );
	
	/* create the players */
	if ( myRank == PLAYER_A_INDEX ) {
		/* Make player A "nice" */
		thisPlayer.probOfCooperateIfOppoCompeted = 0.5;
		thisPlayer.probOfCooperateIfOppoCooperated = 1;
		thisPlayer.iCooperatedLastMove = True;
		thisPlayer.oppoCooperatedLastMove = True;

		thisPlayerIndex = PLAYER_A_INDEX;
		otherPlayerIndex = PLAYER_B_INDEX;
	}
	else {
		/* Make player B "sneaky" */
		thisPlayer.probOfCooperateIfOppoCompeted = 0.25;
		thisPlayer.probOfCooperateIfOppoCooperated = 0.7;
		thisPlayer.iCooperatedLastMove = True;
		thisPlayer.oppoCooperatedLastMove = True;

		thisPlayerIndex = PLAYER_B_INDEX;
		otherPlayerIndex = PLAYER_A_INDEX;
	}

	/* Pre-Generate the percentages for each round, in order to be repeatable */
	srand( 1 );
	for ( round_I = 0; round_I < totalRounds; round_I++ ) {
		randomPercentages[PLAYER_A_INDEX][round_I] = rand() % 100;
		randomPercentages[PLAYER_B_INDEX][round_I] = rand() % 100;
	}
	
	for ( round_I = 0; round_I < totalRounds; round_I++ ) {
		/* Calculate current player's decision */
		playerCooperations[thisPlayerIndex] = player_GetDecision(
			&thisPlayer, randomPercentages[thisPlayerIndex][round_I] );

		/* recv other player's move into playerCooperations[otherPlayerIndex] */
		MPI_Irecv( &playerCooperations[otherPlayerIndex], 1, MPI_CHAR, otherPlayerIndex,
			0, MPI_COMM_WORLD, &request );

		/* send my move to other player */
		MPI_Send( &playerCooperations[thisPlayerIndex], 1, MPI_CHAR, otherPlayerIndex,
			0, MPI_COMM_WORLD );
		MPI_Wait( &request, &recvStatus );

		/* Inform player A of player B's decision */
		thisPlayer.oppoCooperatedLastMove = playerCooperations[otherPlayerIndex];

		/* Calculate the payoffs */
		calculatePayoffs( playerCooperations, payoffResults );
		
		/* update the sums */
		playerSums[thisPlayerIndex] += payoffResults[thisPlayerIndex];
		playerSums[otherPlayerIndex] += payoffResults[otherPlayerIndex];
	}

	printf( "Proc %u: After %d rounds, player A has earnt $%f, player B has earnt $%f\n",
		myRank, totalRounds, playerSums[PLAYER_A_INDEX], playerSums[PLAYER_B_INDEX] );
		
	MPI_Finalize();
	return 0;	
}


