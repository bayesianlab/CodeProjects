#!/bin/bash
filename="$JOB_NAME.c$JOB_ID"
savedir="${HOME}/CodeProjects/MATLAB/factor_models/MLFVAR/bin/completed_tasks/"
if [ -d "$savedir" ]; then
	printf "Job completed $JOB_ID\n" > "$savedir$filename"
else
	mkdir "$savedir"
	printf "Job completed $JOB_ID\n" > "$savedir$filename"
fi
