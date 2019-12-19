#!bin/bash
#$ -S /bin/bash
#$ -q pub8i
#$ -N sim_study
#$ -l mem_free=6G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m ea
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
module load MATLAB
./runhdvardec11 10000 2000 8000 ${DATA} 
