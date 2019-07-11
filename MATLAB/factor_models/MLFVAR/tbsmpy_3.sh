#!bin/bash
#$ -S /bin/bash
#$ -q pub8i
#$ -N tbsmpy_3
#$ -l mem_free=4G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m ea
module load MATLAB
./tbs 2 1 1 ${KEY} mpy.mat



