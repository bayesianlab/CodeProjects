#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N time1
#$ -l mem_free=4G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m ea
module load MATLAB
./RunMdfvar time1.mat 


