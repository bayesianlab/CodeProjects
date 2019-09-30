#!/bin/bash
#$ -S /bin/bash
#$ -q pub8i
#$ -N mpy_tb
#$ -l mem_free=4G
#$ -cwd
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
#$ -ckpt restart
module load MATLAB
./mpy 5000 2000 3000 TimeBreakDataMPY ${DATA} MpyTb
./job_end.sh
