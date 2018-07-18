#!/bin/bash
#SBATCH --nodes 1
#SBATCH --cpus-per-task=12
#SBATCH --partition gpgpu
#SBATCH --gres=gpu:4
#SBATCH --time  02:00:00

module load Singularity

singularity exec --nv -B /tmp:/jobs -B /tmp:/scratch digits.img bash -c "export DIGITS_JOBS_DIR=/jobs && python -m digits"

