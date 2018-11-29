#!bin/bash
#$ -S /bin/bash
#$ -q ist
#$ -N teniter_med
#$ -l mem_free=8G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
module load MATLAB
./kowMcc 5000 1000
