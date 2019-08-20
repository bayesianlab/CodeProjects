#!bin/bash
#$ -S /bin/bash
#$ -q bigmemory
#$ -N k8
#$ -l mem_free=2G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m ea
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
module load MATLAB
./KOW_TBS_Exec 1000 200 800 TimeBreakKowEnd8.mat
