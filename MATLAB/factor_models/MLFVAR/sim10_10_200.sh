#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N sim10_10_200
#$ -l mem_free=4G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
module load MATLAB
./mfvar 10000 1000 1000 2 1 Sim10_10_200.mat
