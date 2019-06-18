#!/usr/bin/env/ python
import csv, subprocess, os
files = os.listdir('/home/precision/CodeProjects/MATLAB/factor_models/MLFVAR/TimeBreakData/')
for f in files:
    qs = "qsub -v DATA={0} tbs_sim_study.sh".format(f)
    print(qs)
    call =subprocess.call(qs, shell=True)
    if call == 1:
        print("failed")
