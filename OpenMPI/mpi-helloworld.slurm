#!/bin/bash

#SBATCH --ntasks=16

##module load OpenMPI/1.10.2-GCC-4.9.2
module load OpenMPI/1.10.2-intel-2017.u2

mpiexec mpi-helloworld
