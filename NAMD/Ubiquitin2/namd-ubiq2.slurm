#!/bin/bash

# SLURM job script, Lev Lafayette (October 2016) 

# Which partition?
#SBATCH --partition=cloud

# Job name:
#SBATCH --job-name ubiquitin2 

# How many cores ?
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=8

# How long to run the job? (hours:minutes:seconds)
#SBATCH --time=00:15:00

# Environmental varibles to make it work:

# NAMD/2.10-intel-2016.u3-mpi
 
module load NAMD/2.10-gompi-2015a-mpi
 
# Launching the job!

mpiexec namd2 namd_1ubq_example.conf  

