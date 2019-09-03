#!/bin/bash
#$ -S /bin/bash
#$ -q free64
#$ -N bmkow
#$ -l mem_free=2G
#$ -cwd
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
#$ -ckpt restart
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m e
module load MATLAB
./kow 1000 200 800 TimeBreakDataKOW ${DATA}
./job_end.sh
