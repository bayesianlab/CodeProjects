#!/usr/bin/env/ python
import csv, subprocess, os
home = os.path.expanduser('~') + '/'
files = os.listdir(home + 'CodeProjects/MATLAB/factor_models/MLFVAR/TBSimData/')
for f in files:
    qs = "qsub -v DATA={0} tbs_sim_study.sh".format(f)
    print(qs)
    call =subprocess.call(qs, shell=True)
    if call == 1:
        print("failed")
