#!/bin/bash
#SBATCH --partition=cloud
#SBATCH --ntasks=1
#SBATCH --nodelist=spartan-rc005
echo $(hostname ) $SLURM_JOB_NAME running $SLURM_JOBID >> hostname.txt
