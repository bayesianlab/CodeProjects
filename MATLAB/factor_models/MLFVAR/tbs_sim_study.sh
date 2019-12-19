#!/bin/bash
#$ -S /bin/bash
<<<<<<< HEAD
#$ -q free64
#$ -N ssdec13
=======
#$ -q pub8i
#$ -N sim_study
>>>>>>> 4406f7633716cc4a80ace821ccbe5c715edd315e
#$ -l mem_free=6G
#$ -cwd
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
#$ -ckpt restart
module load MATLAB
<<<<<<< HEAD
./runhdfvardec12 10000 2000 SimulationData/TimeBreakSimData/ ${DATA} TBSSims/Dec11th 
=======
./runhdvardec11 10000 2000 8000 ${DATA} 
>>>>>>> 4406f7633716cc4a80ace821ccbe5c715edd315e
