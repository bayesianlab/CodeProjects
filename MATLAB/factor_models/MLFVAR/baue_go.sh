#!bin/bash
#$ -S /bin/bash
#$ -q pub8i
#$ -N baue_
#$ -l mem_free=4G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m ea
module load MATLAB
./baue
