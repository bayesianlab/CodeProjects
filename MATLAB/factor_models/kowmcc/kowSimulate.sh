#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N kow_smallt
#$ -l mem_free=8G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
module load MATLAB
./kowSim 2000 500 smallt
