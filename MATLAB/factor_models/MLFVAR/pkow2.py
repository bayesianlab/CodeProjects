#!/usr/bin/env/ python
import csv, subprocess, os
home = os.path.expanduser('~') + '/'
files = os.listdir(home + 'CodeProjects/MATLAB/factor_models/MLFVAR/BigKow/')
c = 0
for f in files:
    qs = "qsub -v DATA={0} tbs_kow2.sh".format(f)
    c += 1
    print(c)
    print(qs)
    call =subprocess.call(qs, shell=True)
    if call == 1:
        print("failed")
