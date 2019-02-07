#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N mlfvar_
#$ -l mem_free=8G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
module load MATLAB
./mfvar 10000 1000 1000 2 1 SimData.mat
