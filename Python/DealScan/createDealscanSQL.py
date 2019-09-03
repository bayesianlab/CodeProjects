import csv
import datetime
import pandas as pd

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

file = 'flendNoDrops.csv'
facIds = []
packIds = []
borrowerId = []
company = []
companyId = []
lender = []
facstart = []
facend = []
bankalloc = []
leadarranger = []
baserate = []
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
            company.append(row[3])
            companyId.append(row[4])
            lender.append(row[5])
            facstart.append(makeStrDate(row[6]))
            facend.append(makeStrDate(row[7]))
            bankalloc.append(row[8])
            leadarranger.append(row[9])
            baserate.append(row[10])
print('Creating frame.')
dealsDF = pd.DataFrame({'FacilityID':facIds, 'PackageID':packIds, 'BorrowerCompanyID':borrowerId,
           'Company':company, 'CompanyID':companyId, 'Lender':lender, 'FacilityStartDate':facstart,
           'FacilityEndDate':facend, 'BankAllocation':bankalloc, 'LeadArrangerCredit':leadarranger,
           'BaseRate':baserate})
print('Pickling frame')
dealsDF.to_pickle('dealsDF_NoDrops')
