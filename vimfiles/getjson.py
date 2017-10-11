import json
import os
from unipath import Path
import sys

print()
def findBuild():
    print(Path(os.getcwd()))
try:
    print(sys.argv[1])
except IndexError:
    pass

findBuild()
fobj = open('/Users/dillonflannery-valadez/Google Drive/CodeProjects/PycharmProjects/YCMpy/ycm_practice.py')
fobj.read
for i in fobj:
    if i.find('compilation_database_folder') != -1:
        print(i)
        break
    else:
        pass




