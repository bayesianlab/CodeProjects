#!bin/bash
#$ -S /bin/bash
#$ -q pub8i
#$ -N jlee
#$ -l mem_free=4G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
module load MATLAB
./SimStudyliu2006Jlee 10000
