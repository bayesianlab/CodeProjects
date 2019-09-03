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

file = 'facility.csv'
facIds = []
packIds = []
borrowerId = []
facstart = []
facend = []
companyName = []
with open(file) as csvfile:
    print('Opened file successfully.')
    readFile = csv.reader(csvfile, delimiter=',')
    c = -1
    for row in readFile:
        c += 1
        if c == 0:
            pass
        else:
            facIds.append(row[0])
            packIds.append(row[1])
            borrowerId.append(row[2])
            facstart.append(makeStrDate(row[4]))
            facend.append(makeStrDate(row[5]))
            companyName.append(row[6])

print('Creating frame.')
dealsDF = pd.DataFrame({'FacilityID':facIds, 'PackageID':packIds, 'BorrowerCompanyID':borrowerId,
            'FacilityStartDate':facstart, 'FacilityEndDate':facend, 'Company':companyName})

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
            bankAlloc.append(row[4])
            lead.append(row[6])

print('Creating frame.')
lenderDF = pd.DataFrame({'FacilityID':facilityID, 'CompanyID':companyID,
                         'BankAllocation':bankAlloc, 'LeadArrangerCredit':lead})

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

engine = sql.create_engine('sqlite:///dealscan.db')
connection = engine.connect()
print('Writing to db')
dealsDF.to_sql('facility', connection, if_exists='replace')
packagesDF.to_sql('packages', connection, if_exists='replace')
lenderDF.to_sql('lenders', connection, if_exists='replace')
facilityPrice.to_sql('facilityPricing', connection, if_exists='replace')


print('Pickling frame')
dealsDF.to_pickle('pandaFacility')
print('Pickling frame')
packagesDF.to_pickle('pandaPackage')
print('Pickling frame')
lenderDF.to_pickle('pandaLender')
print('Pickling frame')
facilityPrice.to_pickle('pandaFacilityPrice')
