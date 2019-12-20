#!/usr/bin/env python
import csv, subprocess, os, glob
home = os.path.expanduser('~') + '/'
#deletetheseOutputFiles = glob.glob(home + 'CodeProjects/MATLAB/factor_models/MLFVAR/bin/outputfiles/*.*')
#deletetheseErrorLogs = glob.glob(home + 'CodeProjects/MATLAB/factor_models/MLFVAR/bin/errorlogs/*.*')
#deletetheseCompletedJobs = glob.glob(home + 'CodeProjects/MATLAB/factor_models/MLFVAR/bin/completed_tasks/*.*')
#
#for file in deletetheseOutputFiles:
#	print 'Deleting: ' + file 
#	os.remove(file)
#for file in deletetheseErrorLogs:
#	print 'Deleting: ' + file 
#	os.remove(file)
#for file in deletetheseCompletedJobs:
#	print 'Deleteing: ' + file
#	os.remove(file)
codedir = 'CodeProjects/MATLAB/factor_models/MLFVAR/'
datadir = 'TimeBreakSimData'
files = os.listdir(home + codedir + datadir)
with open(home + codedir + 'bin/js_log.txt', 'w+') as logfile:
    i=0;
    for f in files:
        qs = "qsub -v DATA={0} simulationtbs.sh".format(f)
        i+=1;
        print'Job number {0}'.format(i)
        print qs
        logfile.write(qs)
        call =subprocess.call(qs, shell=True)
        if call == 1:
            print("failed")
