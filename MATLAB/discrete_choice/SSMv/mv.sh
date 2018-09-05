#!bin/bash
#$ -S /bin/bash
#$ -q pub8i
#$ -l mem_free=2G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
module load MATLAB
./SimStudyMv 30000
