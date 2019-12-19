#!/usr/bin/env python
import csv, subprocess, os, glob, readline
readline.parse_and_bind("tab: complete")
home = os.path.expanduser('~') + '/'
bashfilename = raw_input("""Enter scriptname or enter (Y)es to create script. \
 (obviously do not name your script Y)\n""")
isok="N"
YES = ['Y','y', 'Yes', 'yes']
NO = ['N', 'n', 'No', 'no']
if bashfilename == "Y":
	while isok in NO:
		bashparams=raw_input("Input: Filename, qname, display name,"\
				" Memory, Executable Name\n").split()
		if len(bashparams) < 5:
			print "Invalid input. \n\n"
			isok="N"
			continue
		if not isinstance(int(bashparams[3]), int):
			print("Must be integer amount of memory, try again")
			isok="N"
			continue
		else:
			script_params= tuple(raw_input("Executable and script parameters:\n").split())
			bashparams.append(script_params)
			strings = ["Bash filename", "qname", "Display name", "Memory","Executable Script",
					"Executable parameters"]
			longest=len(max(strings, key=len))
			print "\n\n\n\n\tDisplaying input\n"
			for i in range(len(bashparams)):
				print strings[i].ljust(longest) + ": " + str(bashparams[i]) 
				leader = "#$"
		bashfilename = bashparams[0]+".sh"
		with open(bashfilename, 'w+') as newscript:
			newscript.write("#!/bin/bash\n#$ -S /bin/bash\n#$ -cwd\n")
			newscript.write(leader + " -q "+ bashparams[1]+"\n")
			newscript.write(leader + " -N " +bashparams[2]+ "\n")
			newscript.write(leader + " -l mem_free=" +bashparams[3] + "G" +"\n")
			newscript.write(leader + " -o bin/outputfiles/"+"\n" )
			newscript.write(leader + " -e bin/errorlogs/"+ "\n")
			newscript.write(leader + " -ckpt restart"+"\n")
			newscript.write("module load MATLAB\n")
			newscript.write("./"+bashparams[4] +' ' + ' '.join(bashparams[5]))
		print "\tYour  file\n"
		with open(bashfilename, 'r+') as check:
			lines= check.read().splitlines()
			for q in lines:
				print q
		isok = raw_input("Verify input is ok: Y/N\n")
		assert(isok in ["Y", "y", "N", "n"] ), "Invalid input"
	
multifile = raw_input("Multiple files? (Y)es/(N)o\n")
if multifile in YES:
	datadir = raw_input("Input directory: \n")
	files = os.listdir(datadir)
	print('\n\tList of directory contents')
	for f in files:
		print ' '+ f
	
	submitJobs = raw_input("\n\tSubmit these jobs? Y/N\n")
	if submitJobs in YES:
		i =0
		for f in files:
		        qs = "qsub -v DATA={0} ".format(f)+ bashfilename
		        i+=1;
		        print'Job {0}'.format(i)
		        print qs
		        call =subprocess.call(qs, shell=True)
		        if call == 1:
		            print("failed")
else:
	submitJobs = raw_input("\n\tSubmit these jobs? Y/N\n")
	if submitJobs in YES:
		qs = "qsub " + bashfilename
		call =subprocess.call(qs, shell=True)

