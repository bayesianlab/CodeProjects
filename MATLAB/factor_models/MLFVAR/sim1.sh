#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N sim1
#$ -l mem_free=4G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
module load MATLAB
./MFVARSim1
