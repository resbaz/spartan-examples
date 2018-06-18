
#include <stdlib.h>
#include <stdio.h>
#include <mpi.h>
#include <math.h>

typedef double Coord[2];
typedef char Bool;
const char False = 0; 
const char True = 1; 

/*
typedef struct Particle {
	unsigned int   globalId;
	unsigned int   tag;
	Coord          coord;
} Particle;
*/

Coord attractorPoint = { 0.0, 0.0 };
double movementSpeedDivisor = 3;
unsigned int movementSign = 1;
//int movementSign = 1;

void updateParticleTowardsAttractor( double* xCoordPtr, double* yCoordPtr ) {
	Coord          movementVector;
	unsigned int   dim_I;
	
	movementVector[0] = ( attractorPoint[0] - (*xCoordPtr) ) /
		movementSpeedDivisor;
	movementVector[1] = ( attractorPoint[1] - (*yCoordPtr) ) /
		movementSpeedDivisor;

	for ( dim_I = 0; dim_I < 2; dim_I++ ) {
		movementVector[dim_I] *= movementSign;
	}

	(*xCoordPtr) += movementVector[0];
	(*yCoordPtr) += movementVector[1];
}


double calculateDistanceFromAttractor( double xCoord, double yCoord ) {
	Coord          differenceVector;

	differenceVector[0] = attractorPoint[0] - xCoord;
	differenceVector[1] = attractorPoint[1] - yCoord;

	return sqrt( pow( differenceVector[0], 2 ) + pow( differenceVector[1], 2 ) );
}


int main( int argc, char** argv ) {
	unsigned int  numTimeSteps = 10;
	unsigned int  timeStep_I = 0;
	unsigned int  globalParticlesCount = 100;
	unsigned int  localParticlesCount;
	unsigned int  gParticle_I;
	unsigned int  lParticle_I;
	unsigned int* globalIds = NULL;
	unsigned int* globalTags = NULL;
	double*       globalXCoords = NULL;
	double*       globalYCoords = NULL;
	unsigned int* localIds = NULL;
	unsigned int* localTags = NULL;
	double*       localXCoords = NULL;
	double*       localYCoords = NULL;
	unsigned int  seed;
	double        closestDistance;
	unsigned int  closestParticleId;
	double        distance;
	int           myRank = 0;	
	int           nProc = 0;	

	MPI_Init( &argc, &argv );
	MPI_Comm_rank( MPI_COMM_WORLD, &myRank );
	MPI_Comm_size( MPI_COMM_WORLD, &nProc );

	if ( 0 == myRank ) {
		globalIds = malloc( sizeof(unsigned int) * globalParticlesCount );
		globalTags = malloc( sizeof(unsigned int) * globalParticlesCount );
		globalXCoords = malloc( sizeof(double) * globalParticlesCount );
		globalYCoords = malloc( sizeof(double) * globalParticlesCount );

		printf( "Please input a seed for the random particle coordinates:\n" );
		scanf( "%u", &seed );
		srand( seed );

		/* Initialise the particle properties */
		for ( gParticle_I = 0; gParticle_I < globalParticlesCount; gParticle_I++ ) {
			globalIds[gParticle_I] = gParticle_I;
			globalTags[gParticle_I] = gParticle_I % 10;
			globalXCoords[gParticle_I] = 5 + (double)( rand() % 1000 ) / 200;
			globalYCoords[gParticle_I] = 5 + (double)( rand() % 1000 ) / 200;
		}
	}
	
	// TODO : modify following 5 lines
	// TODO : calculate how many particles per processor, and allocate local particles arrays
	// eg localIds = malloc( sizeof(unsigned int) * localParticlesCount );
	localParticlesCount=globalParticlesCount/nProc;
	localIds = malloc( sizeof(unsigned int) * localParticlesCount );
	localTags = malloc( sizeof(unsigned int) * localParticlesCount );
	localXCoords = malloc( sizeof(double) * localParticlesCount );
	localYCoords = malloc( sizeof(double) * localParticlesCount );
	
	
//	localParticlesCount = globalParticlesCount;
//	localIds = globalIds;
//	localTags = globalTags;
//	localXCoords = globalXCoords;
//	localYCoords = globalYCoords;
		
	
	// TODO : now distribute globalParticles array between processors, into each processor's
	//	localParticles array
	// TODO : advanced 3: use scatterv to work with any number of processors

	
	MPI_Scatter(globalIds,localParticlesCount, MPI_UNSIGNED,
	            localIds, localParticlesCount, MPI_UNSIGNED,
	            0, MPI_COMM_WORLD);	      
/*	
	int *sendcnts=(int*)malloc(nProc*sizeof(int));
	int *displs=(int*)malloc(nProc*sizeof(int));
	int i;
	for(i=0;i<nProc;i++)
	{
	   sendcnts[i]=1;
	   displs[i]=i;
	}
	MPI_Scatterv(globalIds, sendcnts, displs, MPI_UNSIGNED,
	            localIds, localParticlesCount, MPI_UNSIGNED,
	            0, MPI_COMM_WORLD);	            
*/
	                  	            
   MPI_Scatter(globalTags,localParticlesCount, MPI_UNSIGNED,
	            localTags, localParticlesCount, MPI_UNSIGNED,
	            0, MPI_COMM_WORLD);
	MPI_Scatter(globalXCoords,localParticlesCount, MPI_DOUBLE,
	            localXCoords, localParticlesCount, MPI_DOUBLE,
	            0, MPI_COMM_WORLD);
	MPI_Scatter(globalYCoords,localParticlesCount, MPI_DOUBLE,
	            localYCoords, localParticlesCount, MPI_DOUBLE,
	            0, MPI_COMM_WORLD);

	
	for ( timeStep_I = 1; timeStep_I <= numTimeSteps; timeStep_I++ ) {
		closestDistance = 100000.0;

		for ( lParticle_I = 0; lParticle_I < localParticlesCount; lParticle_I++ ) {

			updateParticleTowardsAttractor(
				&localXCoords[lParticle_I],
				&localYCoords[lParticle_I] );

			/* record if particle is closest, and if so what distance is */
			distance = calculateDistanceFromAttractor( 
				localXCoords[lParticle_I],
				localYCoords[lParticle_I] );

			if ( distance < closestDistance ) {
				closestDistance = distance;
				closestParticleId = localIds[lParticle_I];
			}
		}

		printf( "After timestep %d, closest particle is %d, at distance %g\n",
			timeStep_I, closestParticleId, closestDistance );
		// TODO advanced 1: if processor 0, calculate a _global_ minimum
		// TODO advanced 2: if closest global particle distance < 1.0, then flip
		// particles to move away from now on
	   double global_closestDistance;
	   MPI_Reduce(&closestDistance, &global_closestDistance, 1, MPI_DOUBLE, MPI_MIN, 0, MPI_COMM_WORLD);
	   
	   //flip
	   //if (global_closestDistance<1)
	   //{
	   //movementSign=-1;
	   //}
	   
	   
	   if ( 0 == myRank ) {
		   printf( ">>>>>>>>>   Global closest particle is at distance %g\n",
			timeStep_I, global_closestDistance );
		}
	}

	if ( 0 == myRank ) {
		free( globalIds );
		free( globalTags );
		free( globalXCoords );
		free( globalYCoords );
	}
	// TODO: free( localIds ); etc

	free( localIds );
	free( localTags );
	free( localXCoords );
	free( localYCoords );

	MPI_Finalize();

	return 0;	
}


