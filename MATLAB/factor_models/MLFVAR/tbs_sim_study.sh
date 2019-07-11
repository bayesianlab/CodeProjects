#!bin/bash
#$ -S /bin/bash
#$ -q pub8i
#$ -N sim_study
#$ -l mem_free=2G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m ea
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
module load MATLAB
./TimeBreak 10000 2000 8000 ${DATA} 
