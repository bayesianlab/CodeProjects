#!/bin/bash
#$ -S /bin/bash
#$ -q pub8i
#$ -N kowdec11
#$ -l mem_free=10G
#$ -cwd
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
#$ -ckpt restart
module load MATLAB
./runhdfvardec11 10000 2000 TimeBreakDataKOW ${DATA} TBSKow/Dec11th
./job_end.sh
