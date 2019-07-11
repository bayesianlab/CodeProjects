#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N mpy_
#$ -l mem_free=4G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m ea
module load MATLAB
./rmdf 10000 2000 8000 1 mpy.mat
