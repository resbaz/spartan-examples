#!/bin/bash
#SBATCH -p physicaltest
#SBATCH --ntasks=1
module load MATLAB 
matlab -nodesktop -nodisplay -nosplash< mypi.m
