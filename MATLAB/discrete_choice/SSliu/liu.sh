#!bin/bash
#$ -S /bin/bash
#$ -q free48
#$ -N liurun
#$ -l mem_free=2G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
module load MATLAB
./SimStudyliu2006 10000
