#!/bin/bash

#SBATCH -p cloud

#SBATCH --ntasks=1

#SBATCH -t 0:15:00

module load FSL/5.0.9-centos6_64 

# FSL needs to be sourced
source $FSLDIR/etc/fslconf/fsl.sh

srun bet /usr/local/common/FSL/intro/structural.nii.gz test1FSL -f 0.1

