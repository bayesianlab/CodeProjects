#!bin/bash
#$ -S /bin/bash
#$ -q bigmemory
#$ -N kow
#$ -l mem_free=2G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m ea
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
module load MATLAB
./TimeBreakKow 1000 200 800 ${DATA} 
