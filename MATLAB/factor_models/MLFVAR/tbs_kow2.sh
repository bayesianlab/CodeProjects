#!/bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N itskow
#$ -l mem_free=2G
#$ -cwd
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
#$ -ckpt restart
module load MATLAB
./kow 1000 200 800 UnfinishedKOW ${DATA} 
