import pandas as pd
import numpy as np
import os

workingpath = os.getcwd() + '/'
if not os.path.exists('newD'):
    os.mkdir('newD')

for i in range(5):
    df = pd.DataFrame(np.random.normal(0,1,[10,10]))
    df2 = pd.DataFrame(np.random.random_integers(0,100, [10, 10]))
    df2[np.random.random_integers(0,9)] = np.NAN
    df = pd.concat([df2,df], ignore_index=True)
    filename = 'newD/testresults{0}.csv'.format(i)
    print(filename)
    df.to_csv(filename, header=False, index=False)

csvfiles = []
os.chdir('newD/')
for i in os.listdir():
    if i.endswith('.csv'):
        csvfiles.append(i)

results = {}
print(workingpath)
for j in csvfiles:
    df = pd.read_csv(j, header=None, index_col=False)
    nanIndices = pd.isnull(df).any(1).nonzero()[0]
    print('Last NaN {0} in file {1}'.format(nanIndices[-1], j))
    results[j] = list(df.iloc[nanIndices[-1]])
results= pd.DataFrame.from_dict(results).transpose()
results.to_csv(workingpath + 'final.csv', header=False)