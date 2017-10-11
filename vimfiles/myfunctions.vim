function! SetYcmExtraConfPy()
 
python << EOF
import vim 
import os
import json 
configFilePath = '/Users/dillonflannery-valadez/.vim/bundle/YouCompleteMe/.ycm_extra_conf.py'
vim.command("let path = expand('%:p:h')")
path = vim.eval("path")
print "Current Buffer Abs. Path\n" 
print path
os.chdir(path)
os.chdir('..')
os.chdir('build/')
path = os.getcwd()
newline = 'compilation_database_folder = ' + r"'" + path + r"'" + '\n'
print 'New database path'
print newline
with open(configFilePath, 'r') as fobj:
    savefile = fobj.readlines()

savefile[58] = newline
savefile[59] = '\n'

with open(configFilePath, 'w') as fobj:
    fobj.writelines(savefile)

EOF
endfunc
