#!/bin/bash

FIRST=$(sbatch myjob1.slurm)
echo $FIRST
SUB1=$(echo ${FIRST##* })
SECOND=$(sbatch --dependency=afterany:$SUB1 myjob2.slurm)
echo $SECOND
SUB2=$(echo ${SECOND##* })
THIRD=$(sbatch --dependency=afterany:$SUB2 myjob3.slurm)
echo $THIRD
