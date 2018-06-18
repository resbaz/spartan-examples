#!/bin/bash

# SLURM job script, Lev Lafayette (August 2016) 
# Derived from PBS/TORQUE script by Mike Kuiper (March 2007)     

# Job name:
#SBATCH --job-name namd_example_job_01

# How many cores ?
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4

# How long to run the job? (hours:minutes:seconds)
#SBATCH --time=00:15:00

# Environmental varibles to make it work:

module load NAMD/2.12-intel-2017.u2
 
# Launching the job!

srun namd2 Ubiquitin_example.conf 

