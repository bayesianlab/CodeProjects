#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N compare
#$ -l mem_free=8G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
module load MATLAB
./bin/kowCompare 10000 2000 1000 
