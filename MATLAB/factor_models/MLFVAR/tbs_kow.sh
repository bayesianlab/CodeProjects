#!/bin/bash
#$ -S /bin/bash
#$ -q free64
#$ -N test
#$ -l mem_free=2G
#$ -cwd
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
#$ -ckpt restart
module load MATLAB
./test 10 2 8 TimeBreakDataKOW kowTimes100.mat
