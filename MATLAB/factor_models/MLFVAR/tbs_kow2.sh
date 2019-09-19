#!/bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N itskow
#$ -l mem_free=4G
#$ -cwd
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
#$ -ckpt restart
module load MATLAB
./kow2 10000 2000 8000 BigKow ${DATA} BigKowResults
