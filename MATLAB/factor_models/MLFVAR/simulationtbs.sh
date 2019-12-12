#!/bin/bash
#$ -S /bin/bash
#$ -q free64
#$ -N tbssim
#$ -l mem_free=4G
#$ -cwd
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
#$ -ckpt restart
module load MATLAB
./runhdfvardec2 10000 2000 TimeBreakSimData ${DATA} TBSSimDec4 
./job_end.sh
