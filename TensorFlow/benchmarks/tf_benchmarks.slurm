#!/bin/bash
#SBATCH --nodes 1
#SBATCH --partition gpgpu
#SBATCH --gres=gpu:p100:4
#SBATCH --time 01:00:00
#SBATCH --cpus-per-task=24

module load Tensorflow/1.8.0-intel-2017.u2-GCC-6.2.0-CUDA9-Python-3.5.2-GPU

cd benchmarks/scripts/tf_cnn_benchmarks

python tf_cnn_benchmarks.py --num_gpus=4 --batch_size=64 --model=resnet50 --variable_update=parameter_server

