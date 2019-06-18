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
./TimeBreak 2 1 1 ${DATA} 
