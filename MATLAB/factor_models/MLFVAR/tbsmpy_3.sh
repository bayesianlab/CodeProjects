#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N tbsmpy_3
#$ -l mem_free=4G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m ea
module load MATLAB
./tbs1 2 1 1 ${KEY} mpy.mat



