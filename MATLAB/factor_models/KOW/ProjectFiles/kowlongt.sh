#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N kow_longt
#$ -l mem_free=8G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
module load MATLAB
./bin/kowMLF 10000 2000 1000 longt.mat
