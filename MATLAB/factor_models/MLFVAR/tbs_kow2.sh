#!/bin/bash
#$ -S /bin/bash
#$ -q free64
#$ -N kow
#$ -l mem_free=2G
#$ -cwd
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
#$ -ckpt restart
module load MATLAB
./kow_exec 1000 200 800 UnfinishedKOW ${DATA} 
