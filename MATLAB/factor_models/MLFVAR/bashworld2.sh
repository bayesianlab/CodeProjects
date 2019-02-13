#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N world2_
#$ -l mem_free=4G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
module load MATLAB
./mfvar 10000 1000 1000 30 0 WorldData.mat
