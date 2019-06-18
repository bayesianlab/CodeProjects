#!/usr/bin/env/ python
import csv, subprocess
with open("worldtbssheet.csv") as jobs:
    r = csv.reader(jobs)
    c = 0
    for j in r:
	c += 1
        qs = "qsub -v KEY={0} tbswue_go.sh".format(*j)
        print(c, qs)
        call = subprocess.call(qs, shell=True)
        if call == 1:
            print("failed")
 
