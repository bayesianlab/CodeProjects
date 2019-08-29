#!/bin/bash
#$ -S /bin/bash
#$ -ckpt restart 
#$ -q its
#$ -N kow_whole
#$ -l mem_free=2G
#$ -cwd
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
module load MATLAB
./kow_exec 1000 200 800 UnfinishedKOW3 kowTimes100.mat 
