#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N ue_spatial
#$ -l mem_free=4G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
#$ -m ea
module load MATLAB
./ue_spatial 
