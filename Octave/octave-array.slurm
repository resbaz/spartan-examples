#!/bin/bash
#SBATCH --job-name="octave-array"
#SBATCH --ntasks=1
#SBATCH --time=0-00:15:00

# This is the array
#SBATCH --array=1-10

module load Octave/3.8.2-goolf-2015a

octave file-${SLURM_ARRAY_TASK_ID}.oct

