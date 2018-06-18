#!/bin/bash
#SBATCH -p cloud 
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --time=00:10:00

# Note this script does not work (yet). Rmpi has a few issues with OpenMI at the moment.


module load R/3.4.0-GCC-4.9.2
module load OpenMPI/3.0.0-GCC-4.9.2

R CMD BATCH --vanilla xvalidate.R xvalidate.out
