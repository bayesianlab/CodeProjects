#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N world_short
#$ -l mem_free=4G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m ea
module load MATLAB
./mfvar 3000 1000 1000 0 StandardizedRealData.mat
