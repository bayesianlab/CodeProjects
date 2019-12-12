#!/bin/bash
#$ -S /bin/bash
#$ -q pub8i
#$ -N dec4kose_no_ar
#$ -l mem_free=4G
#$ -cwd
#$ -o bin/outputfiles/
#$ -e bin/errorlogs/
module load MATLAB
./runbasedec2 10000 1000 BigKow/kowz_notcentered_kose.mat BigKowResults 
./job_end.sh
