#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --partition cloud
#SBATCH --time  00:05:00

module load Singularity/2.4-GCC-6.2.0

singularity exec vsoch-hello-world-master.simg echo "Hello from inside my container!" > output.txt

