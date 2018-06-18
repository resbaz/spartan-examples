/* Use the File->Save as selection to save this source code*/
/*                  pong.c Generic Benchmark code
 *               Dave Turner - Ames Lab - July of 1994+++
 *
 *  Most Unix timers can't be trusted for very short times, so take this
 *  into account when looking at the results.  This code also only times
 *  a single message passing event for each size, so the results may vary
 *  between runs.  For more accurate measurements, grab NetPIPE from
 *  http://www.scl.ameslab.gov/ .
 */
#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>

int main (int argc, char **argv)
{
   int myproc, size, other_proc, nprocs, i, last;
   double t0, t1, time;
   double *a, *b;
   double max_rate = 0.0, min_latency = 10e6;
   MPI_Request request, request_a, request_b;
   MPI_Status status;

#if defined (_CRAYT3E)
   a = (double *) shmalloc (132000 * sizeof (double));
   b = (double *) shmalloc (132000 * sizeof (double));
#else
   a = (double *) malloc (132000 * sizeof (double));
   b = (double *) malloc (132000 * sizeof (double));
#endif

   for (i = 0; i < 132000; i++) {
      a[i] = (double) i;
      b[i] = 0.0;
   }

   MPI_Init(&argc, &argv);
   MPI_Comm_size(MPI_COMM_WORLD, &nprocs);
   MPI_Comm_rank(MPI_COMM_WORLD, &myproc);

   if (nprocs != 2) {
	   printf("Error: You don't have two processors available.");
	   exit (1);
   }

   other_proc = (myproc + 1) % 2;

   printf("Hello from %d of %d\n", myproc, nprocs);
   MPI_Barrier(MPI_COMM_WORLD);

/* Timer accuracy test */

   t0 = MPI_Wtime();
   t1 = MPI_Wtime();

   while (t1 == t0) t1 = MPI_Wtime();

   if (myproc == 0)
      printf("Timer accuracy of ~%f usecs\n\n", (t1 - t0) * 1000000);

/* Communications between nodes 
 *   - Blocking sends and recvs
 *   - No guarantee of prepost, so might pass through comm buffer
 */

   for (size = 8; size <= 1048576; size *= 2) {
      for (i = 0; i < size / 8; i++) {
         a[i] = (double) i;
         b[i] = 0.0;
      }
      last = size / 8 - 1;

      MPI_Barrier(MPI_COMM_WORLD);
      t0 = MPI_Wtime();

      if (myproc == 0) {

         MPI_Send(a, size/8, MPI_DOUBLE, other_proc, 0, MPI_COMM_WORLD);
         MPI_Recv(b, size/8, MPI_DOUBLE, other_proc, 0, MPI_COMM_WORLD, &status);

      } else {

         MPI_Recv(b, size/8, MPI_DOUBLE, other_proc, 0, MPI_COMM_WORLD, &status);

         b[0] += 1.0;
         if (last != 0)
         b[last] += 1.0;

         MPI_Send(b, size/8, MPI_DOUBLE, other_proc, 0, MPI_COMM_WORLD);

      }

      t1 = MPI_Wtime();
      time = 1.e6 * (t1 - t0);
      MPI_Barrier(MPI_COMM_WORLD);

      if ((b[0] != 1.0 || b[last] != last + 1)) {
         printf("ERROR - b[0] = %f b[%d] = %f\n", b[0], last, b[last]);
         exit (1);
      }
      for (i = 1; i < last - 1; i++)
         if (b[i] != (double) i)
            printf("ERROR - b[%d] = %f\n", i, b[i]);
      if (myproc == 0 && time > 0.000001) {
         printf(" %7d bytes took %9.0f usec (%8.3f MB/sec)\n",
                     size, time, 2.0 * size / time);
         if (2 * size / time > max_rate) max_rate = 2 * size / time;
         if (time / 2 < min_latency) min_latency = time / 2;
      } else if (myproc == 0) {
         printf(" %7d bytes took less than the timer accuracy\n", size);
      }
   }

/* Async communications
 *   - Prepost receives to guarantee bypassing the comm buffer
 */

   MPI_Barrier(MPI_COMM_WORLD);
   if (myproc == 0) printf("\n  Asynchronous ping-pong\n\n");

   for (size = 8; size <= 1048576; size *= 2) {
      for (i = 0; i < size / 8; i++) {
         a[i] = (double) i;
         b[i] = 0.0;
      }
      last = size / 8 - 1;

      MPI_Irecv(b, size/8, MPI_DOUBLE, other_proc, 0, MPI_COMM_WORLD, &request);
      MPI_Barrier(MPI_COMM_WORLD);
      t0 = MPI_Wtime();

      if (myproc == 0) {

         MPI_Send(a, size/8, MPI_DOUBLE, other_proc, 0, MPI_COMM_WORLD);
         MPI_Wait(&request, &status);

      } else {

         MPI_Wait(&request, &status);

         b[0] += 1.0;
         if (last != 0)
         b[last] += 1.0;

         MPI_Send(b, size/8, MPI_DOUBLE, other_proc, 0, MPI_COMM_WORLD);
      }

      t1 = MPI_Wtime();

      time = 1.e6 * (t1 - t0);
      MPI_Barrier(MPI_COMM_WORLD);

      if ((b[0] != 1.0 || b[last] != last + 1))
         printf("ERROR - b[0] = %f b[%d] = %f\n", b[0], last, b[last]);

      for (i = 1; i < last - 1; i++)
         if (b[i] != (double) i)
            printf("ERROR - b[%d] = %f\n", i, b[i]);
      if (myproc == 0 && time > 0.000001) {
         printf(" %7d bytes took %9.0f usec (%8.3f MB/sec)\n",
                  size, time, 2.0 * size / time);
         if (2 * size / time > max_rate) max_rate = 2 * size / time;
         if (time / 2 < min_latency) min_latency = time / 2;
      } else if (myproc == 0) {
         printf(" %7d bytes took less than the timer accuracy\n", size);
      }
   }

/* Bidirectional communications
 *   - Prepost receives to guarantee bypassing the comm buffer
 */

   MPI_Barrier(MPI_COMM_WORLD);
   if (myproc == 0) printf("\n  Bi-directional asynchronous ping-pong\n\n");

   for (size = 8; size <= 1048576; size *= 2) {
      for (i = 0; i < size / 8; i++) {
         a[i] = (double) i;
         b[i] = 0.0;
      }
      last = size / 8 - 1;

      MPI_Irecv(b, size/8, MPI_DOUBLE, other_proc, 0, MPI_COMM_WORLD, &request_b);
      MPI_Irecv(a, size/8, MPI_DOUBLE, other_proc, 0, MPI_COMM_WORLD, &request_a);
      MPI_Barrier(MPI_COMM_WORLD);

      t0 = MPI_Wtime();

      MPI_Send(a, size/8, MPI_DOUBLE, other_proc, 0, MPI_COMM_WORLD);
      MPI_Wait(&request_b, &status);

      b[0] += 1.0;
      if (last != 0)
      b[last] += 1.0;

      MPI_Send(b, size/8, MPI_DOUBLE, other_proc, 0, MPI_COMM_WORLD);
      MPI_Wait(&request_a, &status);

      t1 = MPI_Wtime();
      time = 1.e6 * (t1 - t0);
      MPI_Barrier(MPI_COMM_WORLD);

      if ((a[0] != 1.0 || a[last] != last + 1))
         printf("ERROR - a[0] = %f a[%d] = %f\n", a[0], last, a[last]);
      for (i = 1; i < last - 1; i++)
      if (a[i] != (double) i)
         printf("ERROR - a[%d] = %f\n", i, a[i]);
      if (myproc == 0 && time > 0.000001) {
         printf(" %7d bytes took %9.0f usec (%8.3f MB/sec)\n",
                    size, time, 2.0 * size / time);
         if (2 * size / time > max_rate) max_rate = 2 * size / time;
         if (time / 2 < min_latency) min_latency = time / 2;
      } else if (myproc == 0) {
         printf(" %7d bytes took less than the timer accuracy\n", size);
      }
   }

   if (myproc == 0)
      printf("\n Max rate = %f MB/sec  Min latency = %f usec\n",
               max_rate, min_latency);

   MPI_Finalize();
   return (0);
}

