#!/bin/bash
#$ -S /bin/bash
#$ -ckpt restart 
#$ -q its
#$ -N wue_CK4
#$ -l mem_free=4G
#$ -cwd
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
module load MATLAB
./CorrectedKow4 5000 1000 4000 Unemployment worldue.mat BigKowResults
