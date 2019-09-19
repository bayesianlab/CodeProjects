#!/usr/bin/env/ python
import os
import glob
import sys
import shutil

home = os.path.expanduser('~') + '/'
dest = str(sys.argv[1])
filesToMove = os.listdir(home + 'CodeProjects/MATLAB/factor_models/MLFVAR/TBKOW/Sept10Results')
print filesToMove
for file in filesToMove:
	shutil.move(home + 'CodeProjects/MATLAB/factor_models/MLFVAR/TBKOW/Sept10Results/' +  file, dest)
