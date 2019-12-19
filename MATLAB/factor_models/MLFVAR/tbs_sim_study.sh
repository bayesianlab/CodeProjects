#!/bin/bash
#$ -S /bin/bash
#$ -q free64
#$ -N ssdec13
#$ -l mem_free=6G
#$ -cwd
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
#$ -ckpt restart
module load MATLAB
./runhdfvardec12 10000 2000 SimulationData/TimeBreakSimData/ ${DATA} TBSSims/Dec11th 
