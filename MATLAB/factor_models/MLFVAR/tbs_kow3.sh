#!/bin/bash
#$ -S /bin/bash
#$ -ckpt restart 
#$ -q its
#$ -N resubBeg42
#$ -l mem_free=4G
#$ -cwd
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
module load MATLAB
./KOW 1000 200 800 TimeBreakDataKOW TimeBreakKowBeg42.mat TBKOW 
