#!/usr/bin/env/ python
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

files = os.listdir(home + 'CodeProjects/MATLAB/factor_models/MLFVAR/UnfinishedKOW/')
i=0;
for f in files:
    qs = "qsub -v DATA={0} tbs_kow.sh".format(f)
    i+=1;
    print'Job number {0}'.format(i)
    print qs
    call =subprocess.call(qs, shell=True)
    if call == 1:
        print("failed")
