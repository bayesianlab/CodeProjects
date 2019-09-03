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

file = 'lenders.csv'
facilityID = []
packIds = []
companyID = []
bankAlloc = []
lead = []
with open(file) as csvfile:
    print('Opened file successfully.')
    readFile = csv.reader(csvfile, delimiter=',')
    c = -1
    for row in readFile:
        c += 1
        if c == 0:
            pass
        else:
            facilityID.append(row[0])
            companyID.append(row[1])
            packIds.append(row[0])
            bankAlloc.append(row[4])
            lead.append(row[6])

print('Creating frame.')
lenderDF = pd.DataFrame({'FacilityID':facilityID, 'CompanyID':companyID,
                           'PackageID':packIds, 'BankAllocation':bankAlloc,
                           'LeadArrangerCredit':lead})

engine = sql.create_engine('sqlite:///lenders.db')
connection = engine.connect()
print('Writing to db')
lenderDF.to_sql('lenders', connection, if_exists='replace')
print('Pickling frame')
lenderDF.to_pickle('pandaLender')
