#!/bin/bash
#$ -q test
#$ -N suspend
#$ -l mem_free=4G
#$ -cwd

./test.sh 
./job_end_script.sh
