#!/bin/bash
#$ -S /bin/bash
#$ -N blc
#$ -q free64
#$ -ckpt restart
#$ -r y
#$ -cwd
module load MATLAB
./testmatlabcode

