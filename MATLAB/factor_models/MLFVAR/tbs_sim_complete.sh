#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N wholeset
#$ -l mem_free=2G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m ea
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
module load MATLAB
./TimeBreak 10000 2000 8000 totaltime.mat 
