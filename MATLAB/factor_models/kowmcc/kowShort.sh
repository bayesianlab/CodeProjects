#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N kow_short
#$ -l mem_free=8G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
module load MATLAB
./kowMcc 2000 500 1000
