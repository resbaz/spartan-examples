#!/bin/bash
# This script generates slurm scripts for the standard Gaussian tests.
# To submit the jobs use the following loop:
# for test in {0001..1044}; do sbatch job${test}.slurm; done
# Enjoy submitting 1044 Gaussian test jobs!
# Lev Lafayette, 2017
for test in {0001..1044}
do
cat <<- EOF > job${test}.slurm
#!/bin/bash
#SBATCH --job-name="Gaussian Test ${test}"
#SBATCH --partition=cloud
#SBATCH --ntasks=1
#SBATCH --time=12:00:00
module load Gaussian/g09TEST
g09 < test${test}.com > test${test}.log
EOF
done
