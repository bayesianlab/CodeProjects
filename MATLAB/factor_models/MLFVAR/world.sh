#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N world_
#$ -l mem_free=8G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
module load MATLAB
./mfvar 10000 1000 1000 1 0 WorldData.mat
