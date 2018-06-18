#!/bin/bash
#SBATCH --job-name="Gaussian Test"
#SBATCH --ntasks=1
#SBATCH --time=0-0:10:00

# Change these as appropriate
INPUT_FILE="test0001.com"
OUTPUT_FILE="test0001.log"

module load Gaussian/g09

g09 < $INPUT_FILE > $OUTPUT_FILE
