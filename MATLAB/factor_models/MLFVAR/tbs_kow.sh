#!/bin/bash
#$ -S /bin/bash
#$ -q pub8i
#$ -N bk
#$ -l mem_free=4G
#$ -cwd
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
#$ -ckpt restart
module load MATLAB
./CorrectedKow3 1000 200 800 TimeBreakDataKOW ${DATA} tbk_results
./job_end.sh
