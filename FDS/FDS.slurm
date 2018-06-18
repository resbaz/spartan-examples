#!/bin/bash

#SBATCH --job-name FDS_example_job

#How many nodes/cores? FDS is MPI enabled and can operate across multiple nodes

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4

#What is the maximum time this job is expected to take? (Walltime) 
#Format: Days-Hours:Minutes:Seconds

#SBATCH --time=1-24:00:00

module load FDS

fds inputfile.fds outputfile.fds 
