#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --time=0-12:00:00
#SBATCH --partition=physical

# Load required modules
module load Python/3.5.2-goolf-2015a 

# Launch multiple process python code
echo "Searching for mentions"
time mpiexec -n 1 python3 twitter_search_541635.py -i minitwitter.csv
echo "Searching for topics"
time mpiexec -n 1 python3 twitter_search_541635.py -i minitwitter.csv
echo "Searching for the keyword 'jumping'"
time mpiexec -n 1 python3 twitter_search_541635.py -i minitwitter.csv
