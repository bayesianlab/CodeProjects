#!bin/bash
#$ -S /bin/bash
#$ -q pub8i
#$ -l mem_free=1G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m beas
module load MATLAB
./RunProbit
