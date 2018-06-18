#!/bin/bash
#SBATCH --job-name="SendRecv"
#SBATCH --ntasks=2
#SBATCH --time=0-00:10:00

mpiexec ./mpi-sendrecv
