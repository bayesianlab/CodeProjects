import csv
import datetime
import pandas as pd
import sqlalchemy as sql

def charToInt(chars):
    try:
        return int(float(chars))
    except ValueError:
        return -1

def charToIntToStr(chars):
    return str(charToInt(chars))

def makeStrDate(someStr):
    someDate = charToIntToStr(someStr)
    if int(someDate) == -1:
        return someDate
    else:
        return datetime.datetime.strptime(someDate, '%Y%m%d')

file = 'package.csv'
packIds = []
borrowerId = []
with open(file) as csvfile:
    print('Opened file successfully.')
    readFile = csv.reader(csvfile, delimiter=',')
    c = -1
    for row in readFile:
        c += 1
        if c == 0:
            pass
        else:
            packIds.append(row[0])
            borrowerId.append(row[1])

print('Creating frame.')
packagesDF = pd.DataFrame({'PackageID':packIds, 'BorrowerCompanyID':borrowerId})

engine = sql.create_engine('sqlite:///package.db')
connection = engine.connect()
print('Writing to db')
packagesDF.to_sql('package', connection, if_exists='replace')
print('Pickling frame')
packagesDF.to_pickle('pandaPackage')
