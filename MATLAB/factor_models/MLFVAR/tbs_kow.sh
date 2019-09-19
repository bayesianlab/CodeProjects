#!/bin/bash
#$ -S /bin/bash
#$ -q free64
#$ -N bigkow
#$ -l mem_free=4G
#$ -cwd
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
#$ -ckpt restart
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m e
module load MATLAB
./KOW 1000 200 800 TimeBreakDataKOW ${DATA} TBKOW
./job_end.sh
