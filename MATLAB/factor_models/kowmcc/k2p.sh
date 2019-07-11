#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N k2pTueNight
#$ -l mem_free=8G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
module load MATLAB
./kow2Period 8000 800 4000
