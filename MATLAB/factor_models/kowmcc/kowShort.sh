#!bin/bash
#$ -S /bin/bash
#$ -q pub8i
#$ -N kowshort
#$ -l mem_free=8G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
module load MATLAB
./kowMcc 2000 500
