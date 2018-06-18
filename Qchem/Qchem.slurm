#!/bin/sh

## This is an example script for qchem, offered to show what is possible with a slurm submission script.
##
## Here's the problem: QChem is a multi-node package licensed for use with the physical queue. In 
## order to ensure it's communicating properly with all the nodes it is assigned to, the program reads
## them from a file ($QCHEM_BASE/bin/mpi/machines). This file must be exhaustive, containing all the 
## nodes in the current allocation but none that aren't assigned, and will terminate without starting 
## if this condition isn't met. Unfortunately, those nodes aren't known in advance of the job being 
## assigned resources, which results in a precedence problem. We must write this file *after* the job
## starts on the queue but before running the application itself.
##
## This can be achieved by using the scontrol slurm command to build the file dynamically based on 
## slurm's list of assigned nodes, and parsed by awk.
##
## The desired format is simply: 
##
## servername   slots=6
## servername2  slots=6
##


#SBATCH --job-name=MPI_18_worker_test
#SBATCH --nodelist=spartan-bm[003-5]
#SBATCH --partition=physical
#SBATCH --time=48:00:00
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=6

#this script will generate a list of nodes for qchem to use and ensure they line up with
#the nodes assigned by slurm. Make sure that (--nodes * --ntasks-per-node) = -np value on the
#qchem execution line below.
#
# e.g. --nodes=3
# --ntasks-per-node=6
#
# qchem -np 18 <input> <output>


## The following variable must point to the base of a valid QChem installation. This is a dummy value 
## but conforms to the naming conventions we use on Spartan for version and compiler.

QCHEM_BASE=/usr/local/easybuild/software/qchem/4.4.0-gompi-2015a

module load OpenMPI/1.10.2-GCC-4.9.2

scontrol show hostname ${SLURM_JOB_NODELIST} | awk '{print $2 " slots=6"}' > $QCHEM_BASE/bin/mpi/machines

qchem -np 18 h2o_ccsdt.in h2o_ccsdt.dan.out
