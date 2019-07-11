#!bin/bash
#$ -S /bin/bash
#$ -q pub8i
#$ -N tswue
#$ -l mem_free=4G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m ea
#$ -o bin/
#$ -e bin/ 
module load MATLAB
./tbs1 1000 200 800 ${KEY} worldue.mat
