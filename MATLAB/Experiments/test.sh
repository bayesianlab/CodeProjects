#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N test
#$ -l mem_free=4G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
module load MATLAB
./CallTest
