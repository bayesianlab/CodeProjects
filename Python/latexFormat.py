#!/usr/bin/env python
import sys
import pandas as pd

def importTable(filename):

    table = pd.read_csv(filename, header=None)
    return table

def makeTable(nRows, nCols, fname, texfile):
    table = importTable(fname)
    rc = table.shape
    table = table.round(3)
    with open(texfile, 'w') as tex:
        for i in range( rc[0] ):
            print '& ' + ' & '.join( map(str,table.iloc[i,:].tolist() ))+ ' \\\\' 
            tex.write('& ' + ' & '.join( map(str,table.iloc[i,:].tolist() ))+ ' \\\\' + '\n') 
        tex.close()
    
fname = str(sys.argv[1])
texfile = str(sys.argv[2])
X = importTable(fname)
makeTable(1,1, fname, texfile)

    




    
    

