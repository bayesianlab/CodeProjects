#!/usr/bin/env/ python
import csv, subprocess, os, glob, datetime
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
jobname = 'mpy_tb'
codedir = 'CodeProjects/MATLAB/factor_models/MLFVAR/'
files = os.listdir(home + codedir + 'TimeBreakDataMPY/')
datestr = str(datetime.datetime.now())
datestr =  datestr[0:datestr.find('.')].replace(':', '_').replace('-', '_').replace(' ', '_')
with open(home + codedir + 'bin/' + 'js_log_' + jobname + datestr + '.txt', 'w+') as logfile:
    i=0;
    for f in files:
        qs = "qsub -v DATA={0} mpy_tb.sh".format(f)
        i+=1;
        print'Job number {0}'.format(i)
	print qs
        logfile.write(qs + '\n')
#        call =subprocess.call(qs, shell=True)
#        if call == 1:
#            print("failed")
