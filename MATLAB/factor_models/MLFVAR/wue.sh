#!/bin/bash
#$ -S /bin/bash
#$ -ckpt restart 
#$ -q its
#$ -N wue_iden1
#$ -l mem_free=4G
#$ -cwd
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
module load MATLAB
./iden1 5000 1000 4000 Unemployment worldue.mat BigKowResults
