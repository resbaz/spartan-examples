#!/bin/bash

# Set the partition

#SBATCH -p cloud 

# Set the number of processors that will be used.
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8

# Set the walltime (10 hrs)

#SBATCH --time=10:00:00

# Load the environment variables

module load BLAST/2.2.26-Linux_x86_64

# Run the job

blastall -i ./rat-ests/rn_est -d ./dbs/rat.1.rna.fna -p blastn -e 0.05 -v 5 -b 5 -T F -m 9 -o rat_blast_tab.txt -a 8
