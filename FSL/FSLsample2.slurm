#!/bin/bash
#SBATCH -p cloud
#SBATCH --ntasks=8
#SBATCH -t 0:00:05

module load FSL/5.0.9-centos6_64 

# FSL needs to be sourced
source $FSLDIR/etc/fslconf/fsl.sh

srun -n 8 bet /usr/local/common/FSL/intro/structural.nii.gz test2FSL -f 0.1

