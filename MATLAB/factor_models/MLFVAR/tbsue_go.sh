#!bin/bash
#$ -S /bin/bash
#$ -q pub8i
#$ -N tbsue
#$ -l mem_free=4G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m ea
#$ -e bin/
#$ -o bin/
module load MATLAB
./tbs1 1000 200 800 ${KEY} ue.mat



