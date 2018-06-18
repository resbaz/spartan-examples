#!/bin/bash

#SBATCH -p cloud
#SBATCH --time=0-00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=4

module load ORCA/3_0_3-linux_x86-64-OpenMPI-1.6.5
source ~/.bashrc

$EBROOTORCA/orca orca.in 1> orcaNEW3.out
