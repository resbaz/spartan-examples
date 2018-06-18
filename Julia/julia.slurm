#!/bin/bash
#SBATCH -p cloud
#SBATCH ntasks=1

module load Julia/0.6.0-binary
julia simple.jl
