#!/bin/bash
#SBATCH --partition=gpgpu
#SBATCH --gres=gpu:4
#SBATCH --account=hpcadmingpgpu
module load QuantumESPRESSO/5.4.0-intel-2016.u3
module load CUDA/9.0.176-intel-2017.u2
