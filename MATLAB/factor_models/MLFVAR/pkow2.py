#!/usr/bin/env/ python
import csv, subprocess, os
home = os.path.expanduser('~') + '/'
files = os.listdir(home + 'CodeProjects/MATLAB/factor_models/MLFVAR/KOW_Part2/')
for f in files:
    qs = "qsub -v DATA={0} tbs_kow.sh".format(f)
    print(qs)
    call =subprocess.call(qs, shell=True)
    if call == 1:
        print("failed")
