#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N tsmpy_
#$ -l mem_free=4G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m ea
module load MATLAB
./tbs 2000 200 1000 mpy.mat
