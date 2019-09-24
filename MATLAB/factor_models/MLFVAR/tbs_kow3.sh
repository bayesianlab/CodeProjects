#!/bin/bash
#$ -S /bin/bash
#$ -ckpt restart 
#$ -q its
#$ -N bigJobs
#$ -l mem_free=4G
#$ -cwd
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
module load MATLAB
./The_Real_Kow 10000 2000 8000 UnfinishedKOW3 ${DATA} BigKowResults2 
