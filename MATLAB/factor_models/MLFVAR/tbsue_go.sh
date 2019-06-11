#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N tbsue
#$ -l mem_free=4G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m ea
module load MATLAB
./tbs 2 1 1 ${KEY} ue.mat



