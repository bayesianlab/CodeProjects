#!bin/bash
#$ -S /bin/bash
#$ -q pub8i
#$ -l mem_free=8G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
module load MATLAB
./SimStudyNewP 30000
