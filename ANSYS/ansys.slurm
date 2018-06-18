#!/bin/bash
# SBATCH --account=punim0396 
# SBATCH --partition=punim0396
#SBATCH --job-name="ANSYS test"
#SBATCH --partition=physical-cx4
#SBATCH --ntasks=1
#SBATCH --time=0-00:10:00
#SBATCH --gres=aa_r+1%aa_r_hpc+12

module load ansys/19.0-intel-2017.u2

ansys19 -b < OscillatingPlate.inp > OscillatingPlate.db
