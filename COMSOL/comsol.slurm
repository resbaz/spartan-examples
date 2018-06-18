#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
# You might need an external license file
# export LM_LICENSE_FILE=port@licenseserver
 
module load COMSOL/5.2

# Example batch command from csiro.org.au
comsol batch -inputfile mymodel.mph  -outputfile mymodelresult.mph -batchlog mybatch.log -j b1 -np 8 -mpmode owner
