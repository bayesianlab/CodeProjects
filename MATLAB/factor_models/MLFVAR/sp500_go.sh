#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N sp500_
#$ -l mem_free=4G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m ea
module load MATLAB
./RunMdfvarBlock 5000 1000 100 0  weeklyReturns.mat 
