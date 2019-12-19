#!/bin/bash
#$ -S /bin/bash
#$ -q its
#$ -N whole
#$ -l mem_free=8G
#$ -cwd
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
#$ -ckpt restart 
module load MATLAB
./runhdfvardec12 10000 2000 SimulationData/TimeBreakSimData/ totaltime.mat TBSSims/Dec11th
