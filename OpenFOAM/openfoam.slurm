#!/bin/bash
# SBATCH --account=punim0396
# SBATCH --partition=punim0396
#SBATCH --job-name="OpenFOAM test"
#SBATCH --partition=physical-cx4
#SBATCH --ntasks=12
#SBATCH --time=0-00:10:00

module load OpenFOAM/5.0-intel-2017.u2

source $FOAM_BASH

# OpenFOAM commands go here. For example;

srun -n 1 decomposePar -latestTime -force
srun -n 12  pimpleFoam -parallel
srun -n 1 recontructPar -latestTime 
