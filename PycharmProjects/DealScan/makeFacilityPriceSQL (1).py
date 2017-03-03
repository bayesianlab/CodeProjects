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

file = 'current_facility_pricing.csv'
facilityID = []
baseRate = []
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
            baseRate.append(row[1])

print('Creating frame.')
facilityPrice = pd.DataFrame({'FacilityID':facilityID, 'BaseRate':baseRate})

engine = sql.create_engine('sqlite:///facilityPrice.db')
connection = engine.connect()
print('Writing to db')
facilityPrice.to_sql('facilityPricing', connection, if_exists='replace')
print('Pickling frame')
facilityPrice.to_pickle('pandaFacilityPrice')
