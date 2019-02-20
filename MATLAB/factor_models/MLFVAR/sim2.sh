#!bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N sim2
#$ -l mem_free=4G
#$ -cwd
#$ -notify 
#$ -M dillonflann@gmail.com
module load MATLAB
./MFVARSim2
