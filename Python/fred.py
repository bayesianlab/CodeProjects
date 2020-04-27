#! /usr/bin/python3.5
#1593ee3cad0646216ab4b80aa9f63cd2

from fredapi import Fred
import requests as req
import pandas as pd
import csv
import pickle
import os.path
from os import path
import sys

RedownloadData = input('Redownload Data? y/n ')
YES = ['Y', 'y', 'Yes', 'yes']
if RedownloadData in YES:
    flag = 1
else:
    flag =0
        

fred = Fred(api_key='1593ee3cad0646216ab4b80aa9f63cd2') 
search = fred.search('Jobless Claims')
Code = ['AL', 
'AK', 
'AZ', 
'AR',
'CA',
'CO',
'CT',
'DE',
'DC',
'FL',
'GA',
'HI',
'ID',
'IL',
'IN',
'IA',
'KS',
'KY',
'LA',
'ME',
'MD',
'MA',
'MI',
'MN',
'MS',
'MO',
'MT',
'NE',
'NV',
'NH',
'NJ',
'NM',
'NY',
'NC',
'ND',
'OH',
'OK',
'OR',
'PA',
'RI',
'SC',
'SD',
'TN',
'TX',
'UT',
'VT',
'VA',
'WA',
'WV',
'WI',
'WY']
if not path.exists('/home/precision/CodeProjects/Python/fredata.p') or  flag == 1:
   # print('Redownloading data')
   # c =0
   # ed = {}
   # for i in search['id']:
   #     if 'CLAIMS' in i:
   #         if i[0:2] in Code:
   #             c = c+ 1;
   #             print(i, c)
   #             x=fred.get_series(i) 
   #             ed[i] = x
   # pickle.dump( ed, open( "fredata.p", "wb"  )  )
    ed=pickle.load(open('fredata.p', 'rb'))
    FredFrame = pd.DataFrame(ed)
    FredFrame = FredFrame.T
    print(FredFrame)
    FredFrame=FredFrame.iloc[:, 1859:]
    print(FredFrame) 
    FredFrame.to_csv('JoblessClaims.csv')

    print('Downloading covid data') 
    with req.Session() as s:
        p= req.get('https://usafactsstatic.blob.core.windows.net/public/data/covid-19/covid_confirmed_usafacts.csv')
        down = p.content.decode('UTF-8')
        cr = csv.reader(down.splitlines(),delimiter=',')
        cr = list(cr)
        with open('statebystate.csv', 'w') as f:
            writer = csv.writer(f)
            writer.writerows(cr)
            print('Wrote statebystate.csv file')


else:
    print('Found FRED pickle')
    ed=pickle.load(open('fredata.p', 'rb'))
    FredFrame = pd.DataFrame(ed)
    FredFrame = FredFrame.T
    FredFrame=FredFrame.iloc[1100:]
    FredFrame.T.to_csv('JoblessClaims.csv')






stateCovid = pd.read_csv('statebystate.csv')

stateCovid=stateCovid.groupby('State').sum()
#print(stateCovid)
stateCovid=stateCovid.drop(columns=['countyFIPS','stateFIPS'])
#print(stateCovid)
stateCovid.to_csv('statecovid.csv')
