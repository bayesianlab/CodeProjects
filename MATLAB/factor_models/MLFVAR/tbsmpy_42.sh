#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N tbsmpy_42
#$ -l mem_free=4G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m ea
module load MATLAB
./tbs 1000 200 1000 42 mpy.mat



