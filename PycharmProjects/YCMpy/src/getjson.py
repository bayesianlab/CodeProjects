import json
import os



ycmconfpypath = '/Users/dillonflannery-valadez/.vim/bundle/YouCompleteMe/.ycm_extra_conf.py'
print os.getcwd()
os.chdir('..')
os.chdir('build/')

path = os.getcwd()

newline = 'compilation_path = ' + r"'" + path + r"'" + '\n'
print newline
with open(ycmconfpypath, 'r') as fobj:
    savefile = fobj.readlines()
savefile[58] = newline
savefile[59] = '\n'

with open(ycmconfpypath, 'w') as fobj:
    fobj.writelines(savefile)








