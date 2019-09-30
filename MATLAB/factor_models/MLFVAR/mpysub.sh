#!/bin/bash
#$ -S /bin/bash
#$ -q bigmemory
#$ -N mpy
#$ -l mem_free=4G
#$ -cwd
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
#$ -ckpt restart
module load MATLAB
./CorrectedKow4 10000 2000 8000 MpyData mpy.mat MpyResults
./job_end.sh
