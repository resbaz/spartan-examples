#!/bin/bash
#SBATCH -p cloud
#SBATCH --ntasks=1
module load MATLAB/2016a
matlab -nodesktop -nodisplay -nosplash< polar-plot.m
