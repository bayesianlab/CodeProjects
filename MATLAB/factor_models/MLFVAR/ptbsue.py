#!/usr/bin/env/ python
import csv, subprocess
with open("tbssheet.csv") as jobs:
    r = csv.reader(jobs)
    for j in r:
        qs = "qsub -v KEY={0} tbsue_go.sh".format(*j)
        print(qs)
        call =subprocess.call(qs, shell=True)
        if call == 1:
            print("failed")
 
