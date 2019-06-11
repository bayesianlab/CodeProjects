#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N tbsmpy_19
#$ -l mem_free=4G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m ea
module load MATLAB
./tbs 1000 200 1000 19 mpy.mat



