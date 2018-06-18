#!/bin/bash
# 2 nodes, 2 tasks per node = 4 cores
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --time=0-12:00:00
#SBATCH --partition=physical

# Load required modules
module load Python/3.5.2-goolf-2015a 

# Launch multiple process python code
echo "Searching for mentions"
time mpiexec python3 twitter_search_541635.py -i minitwitter.csv -m
echo "Searching for topics"
time mpiexec srun python3 twitter_search_541635.py -i minitwitter.csv -t
echo "Searching for the keyword 'jumping'"
time mpiexec python3 twitter_search_541635.py -i minitwitter.csv -s jumping
