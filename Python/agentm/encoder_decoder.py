#!/usr/bin/python
from random import seed 
from random import randint 
import string 
import pandas as pd
import numpy as np
import sys
np.random.seed(101)
z=[]

INPUTFILE= sys.argv[1]
msg = []
with open(INPUTFILE, 'r') as f:
    for line in f:
        if len(line.split()) == 0:
            continue
        else:
            msg.append(line.split())


KEY =sys.argv[2] 
KEY=pd.read_csv(KEY)
maxkey = KEY.max()[0]
Values = sys.argv[3]
Values = pd.read_csv(Values)
CIPHER = []
if sys.argv[4] == 'encode':
    c = 0
    for i in msg:
        for j in i:
            for q in j:
                if q in string.ascii_letters:
                    q=q.lower()
                    CIPHER.append((KEY.iloc[c][0]+Values[Values.Letters == q].Value.iloc[0])%maxkey)
                    c = c+1
    with open('cipher.txt', 'w+') as f:
        for i in CIPHER:
            out = str(i) + ' '
            f.write(out)



elif sys.argv[4] == 'decode':
    c = 0
    print "Decoding "
    secretmessage = []
    for i in msg:
        for j in i:
            check= int(j) - KEY.iloc[c][0]
            while check < 0:
                check= check + maxkey
            let = check % maxkey
            let = Values[Values.Value == let].Letters.iloc[0]
            if let == 'x':
                secretmessage.append(let)
                secretmessage.append(' ')
            else:
                secretmessage.append(let)
            c = c + 1
    print ''.join(secretmessage)
