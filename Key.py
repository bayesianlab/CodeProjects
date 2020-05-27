#!/usr/bin/python
from random import seed
from random import randint
import string
import pandas as pd
import numpy as np
y= np.sort(np.random.choice(np.arange(0, 1000), size=26, replace=False))
lets= list(string.ascii_lowercase)
D = {'Letters': lets,"Value": y}
Values = pd.DataFrame.from_dict(D)
Values.to_csv('LetterValues.csv', index=False)
key = np.random.choice(y, size=1000)

KEY = {"KEY":key}
KEY=pd.DataFrame.from_dict(KEY)
KEY.to_csv("Key.csv",index=False)
