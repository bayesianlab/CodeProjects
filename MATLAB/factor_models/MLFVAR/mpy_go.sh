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
./mpy
