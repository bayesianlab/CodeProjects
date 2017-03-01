from collections import Counter
import csv
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import datetime
import sqlalchemy as sql
import sqlalchemy.orm as sqlorm
import os


if os.path.isfile('dealscan.db'):
    os.remove('dealscan.db')

"""
Dont give me any data with NA's in the time components!!
"""

def newPackage(previousPacakgeID, currentPackageID):
    if previousPacakgeID != currentPackageID:
        return True
    else:
        return False

def newLender(previousLender, currentLender):
    if previousLender != currentLender:
        return True
    else:
        return False

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


def removeDuplicates(someList):
    return list(set(someList))

def dropDups(someList, indx):
    duplicateIndxs = []
    j = indx + 1
    while j < len(someList):
        if someList[indx] == someList[j] and j not in duplicateIndxs:
            duplicateIndxs.append(j)
        j += 1
    return duplicateIndxs

def searchAndDropDups(lenders, allocation, startEndDates, leadList):
    lenLenders = len(lenders)
    k = 0
    while k < lenLenders:
        drops = dropDups(lenders, k)
        for i in reversed(drops):
            del lenders[i]
            del allocation[i]
            del startEndDates[i]
            del leadList[i]
        lenLenders = len(lenders)
        if lenLenders == 1:
            break
        k += 1
    return (lenders, allocation, startEndDates, leadList)



def searchForMatch(file, borrowerIdCol, lenderIdCol, packageIdCol, allocationCol, startDateCol, endDateCol,
                   leadArrangerCredit, baseRateCol):
    with open(file) as csvfile:
        scanReader = csv.reader(csvfile, delimiter=',')
        lendIdBorrowerId = {}
        allocationDict = {}
        dateDict = {}
        baseRateDict = {}
        leadArrangerDict = {}
        c = 0
        d = 0
        lenders = []
        allocation = []
        startEndDates = []
        baseRateList = []
        leadArrangerList = []
        previousPackageID = ''
        borrowerCompanyID = ''
        for row in scanReader:
            # if d==100:
            #     break
            if c == 0:
                c += 1
                d += 1
                continue
            else:
                if c == 1:
                    borrowerCompanyID = row[borrowerIdCol]
                    previousPackageID = row[packageIdCol]
                    lenders.append(row[lenderIdCol])
                    allocation.append(row[allocationCol])
                    timeElapsed = (makeStrDate(row[endDateCol]) - makeStrDate(row[startDateCol])).days
                    startEndDates.append(timeElapsed)
                    baseRateList.append(row[baseRateCol])
                    leadArrangerList.append(row[leadArrangerCredit])
                else:
                    if not newPackage(previousPackageID, row[packageIdCol]):
                        lenders.append(row[lenderIdCol])
                        allocation.append(row[allocationCol])
                        timeElapsed = (makeStrDate(row[endDateCol])-makeStrDate(row[startDateCol])).days
                        startEndDates.append(timeElapsed)
                        baseRateList.append(row[baseRateCol])
                        leadArrangerList.append(row[leadArrangerCredit])
                    else:
                        try:
                            lendAllocTup = searchAndDropDups(lenders, allocation, startEndDates, leadArrangerList)
                            lendIdBorrowerId[borrowerCompanyID] += lendAllocTup[0]
                            allocationDict[borrowerCompanyID] += lendAllocTup[1]
                            dateDict[borrowerCompanyID] += lendAllocTup[2]
                            leadArrangerDict[borrowerCompanyID] +=  lendAllocTup[3]
                            baseRateDict[borrowerCompanyID] += baseRateList
                            borrowerCompanyID = row[borrowerIdCol]
                            previousPackageID = row[packageIdCol]
                            # Reset searches!
                            lenders = []
                            allocation = []
                            startEndDates = []
                            baseRateList = []
                            leadArrangerList = []
                            lenders.append(row[lenderIdCol])
                            allocation.append(row[allocationCol])
                            timeElapsed = (makeStrDate(row[endDateCol]) - makeStrDate(row[startDateCol])).days
                            startEndDates.append(timeElapsed)
                            baseRateList.append(row[baseRateCol])
                            leadArrangerList.append(row[leadArrangerCredit])
                        except KeyError:
                            lendAllocTup = searchAndDropDups(lenders, allocation, startEndDates, leadArrangerList)
                            lendIdBorrowerId[borrowerCompanyID] = lendAllocTup[0]
                            allocationDict[borrowerCompanyID] = lendAllocTup[1]
                            dateDict[borrowerCompanyID] = lendAllocTup[2]
                            leadArrangerDict[borrowerCompanyID] = lendAllocTup[3]
                            baseRateDict[borrowerCompanyID] = baseRateList
                            borrowerCompanyID = row[borrowerIdCol]
                            previousPackageID = row[packageIdCol]
                            # Reset searches!
                            lenders = []
                            allocation = []
                            startEndDates = []
                            baseRateList = []
                            leadArrangerList = []
                            lenders.append(row[lenderIdCol])
                            allocation.append(row[allocationCol])
                            timeElapsed = (makeStrDate(row[endDateCol]) - makeStrDate(row[startDateCol])).days
                            startEndDates.append(timeElapsed)
                            baseRateList.append(row[baseRateCol])
                            leadArrangerList.append(row[leadArrangerCredit])

                c += 1
                d += 1
        try:
            lendAllocTup = searchAndDropDups(lenders, allocation, startEndDates, leadArrangerList)
            lendIdBorrowerId[borrowerCompanyID] += lendAllocTup[0]
            allocationDict[borrowerCompanyID] += lendAllocTup[1]
            dateDict[borrowerCompanyID] += lendAllocTup[2]
            leadArrangerDict[borrowerCompanyID] += lendAllocTup[3]
            baseRateDict[borrowerCompanyID] += baseRateList
        except KeyError:
            lendAllocTup = searchAndDropDups(lenders, allocation, startEndDates, leadArrangerList)
            lendIdBorrowerId[borrowerCompanyID] = lendAllocTup[0]
            allocationDict[borrowerCompanyID] = lendAllocTup[1]
            dateDict[borrowerCompanyID] = lendAllocTup[2]
            baseRateDict[borrowerCompanyID] = baseRateList
            leadArrangerDict[borrowerCompanyID] = lendAllocTup[3]

    return (lendIdBorrowerId, allocationDict, dateDict, baseRateDict, leadArrangerDict)

def countRepeats(lenderDict):
    cnt = Counter()
    countList = []
    for company in lenderDict:
        for lender in lenderDict[company]:
            cnt[lender] += 1
        for j in cnt:
            countList.append(cnt[j])
        cnt = Counter()
    return countList

"""
This chunk of code gets the statistics about the number of lenders
per company, but it does not search for repeated relationships
"""
#
# lendIdBorrowerId = searchForMatch('flend.csv', 2, 4, 1, 6)
# relationships = lendIdBorrowerId[0]
# numberRelationships = []
# for k in relationships:
#     numberRelationships.append(len(relationships[k]))
# lenderRelationships = np.array(numberRelationships)
# f = pd.DataFrame(numberRelationships)
# print(f.describe())
# print(np.std(lenderRelationships))

"""
This code converts the relationships to a dataframe. Counting
repeated relationships.
"""

# cl = countRepeats(lendIdBorrowerId[0])
# frame = pd.DataFrame(cl, columns=['count'])
#
# fig, ax = plt.subplots()
# bins = [1,2, 3, 4, 5, 10]
# freqCount = pd.DataFrame(frame['count'].value_counts())
# freqCount.to_csv('freqCount.csv', ',')

# subset1 = frame[frame['count'] < 11]
# ax.hist(subset1['count'], histtype='stepfilled', edgecolor='black',rwidth=.8)
# ax.set_title('Borrowers with relationships less than or equal to 10')

# fig1, ax1 = plt.subplots()
# subset2 = frame[(frame['count'] > 11) & (frame['count'] < 21)]
#
# ax1.hist(subset2['count'], histtype='stepfilled', edgecolor='black', bins=8)
# ax1.set_title('Borrowers with relationships between 11 and 20')
#
# fig2, ax2 = plt.subplots()
# subset3 = frame[(frame['count'] >= 21)]
# bins = [21, 40, 41, 60, 61, 80, 81, 420 ]
# ax2.hist(subset3['count'], bins, edgecolor='black')
# ax2.set_title('All other borrowers (21-419)')

# plt.show()

"""
This code looks for banks that gave more than 50%.
The dataset droppoed all obs that did not have any data about allocations.
"""

# lenderBorrower = searchForMatch('flendDroppedAllocations.csv', 2, 4, 1, 6)

# moreThan50 = 0
# moreThan50Repeat = 0
# for i, item in enumerate(lenderBorrower[1]):
#     cnt = Counter()
#     numBanks = len(lenderBorrower[1][item])
#     for j in range(numBanks):
#         bankAlloc = lenderBorrower[1][item][j]
#         if float(bankAlloc) > 50:
#             bankId = lenderBorrower[0][item][j]
#             # print(bankId, bankAlloc)
#             # print(int(float(bankId)))
#             cnt[bankId] += 1
#             moreThan50 += 1
#     for key in cnt:
#         if cnt[key] > 1:
#             moreThan50Repeat += 1

# print(moreThan50)
# print(moreThan50Repeat)
#
# work = searchForMatch('flend.csv', 2, 4, 1, 8, 6, 7, 10)
# print(work[0])
# print(work[1])
# print(work[2])
# print(work[3])


# dealsDF = pd.read_pickle('dealsDF_NoDrops')
# distinctPackageIDs = dealsDF['PackageID'].unique()
#
#
# def hasOneArranger(companyIDs):
#     if len(set(companyIDs)) == 1:
#         return True
#     else:
#         return False
#
# def dropMultipleArrangers(dataFrame, distinctPackageIDs):
#     for j in distinctPackageIDs:
#         smallFrame = dataFrame[dataFrame['PackageID'] == j][['CompanyID', 'LeadArrangerCredit']]
#         smallFrame = smallFrame[smallFrame['LeadArrangerCredit'] == 'Yes']
#         if not hasOneArranger(smallFrame.CompanyID):
#             dataFrame = dataFrame[dataFrame.PackageID != j]
#     print(dataFrame.shape)
#     return dataFrame
#
# dropMultipleArrangers(dealsDF, distinctPackageIDs)


# results = searchForMatch('flend.csv', 2, 4, 1, 9, 6,7, 9, 9)
# print(results[0])

# count = 0
# for k in results[4]:
#     cnt = Counter()
#     for i in results[4][k]:
#         cnt[i] += 1
#     if cnt['Yes'] == 1:
#         count += 1
# print(count)

def searchData(file):
    with open(file) as csvfile:
        scanReader = csv.reader(csvfile, delimiter=',')
        d = 0
        c = -1
        oneLead = 0
        leadArrangerD = {}
        bankD = {}
        packageD = {}
        uniqueLenderD = {}
        packagesToKeep = {}
        baseRateD = {}
        packagesToKeep['keep'] = []
        for row in scanReader:
            d += 1
            c += 1
            if c == 0:
                pass
            elif c == 1:
                previousPackageID = row[1]
                borrowerID = row[2]
                leadArrangerD[borrowerID] = [row[9]]
                bankD[borrowerID] = [row[4]]
                packageD[borrowerID] = row[1]
                baseRateD[previousPackageID] = [row[10]]
                continue
            elif previousPackageID != row[1]:
                uniqueLenderD = addToUniqueKeys(bankD, borrowerID, uniqueLenderD)
                if checkIfOne(bankD[borrowerID], leadArrangerD[borrowerID]):
                    oneLead += 1
                    packagesToKeep['keep'].append(packageD[borrowerID])
                borrowerID = row[2]
                leadArrangerD[borrowerID] = [row[9]]
                bankD[borrowerID] = [row[4]]
                packageD[borrowerID] = row[1]
                previousPackageID = row[1]
                baseRateD[previousPackageID] = [row[10]]
            else:
                baseRateD[previousPackageID].append(row[10])
                leadArrangerD[borrowerID].append(row[9])
                bankD[borrowerID].append(row[4])
                previousPackageID = row[1]
            # if d == 40:
            #     break
    uniqueLenderD = addToUniqueKeys(bankD, borrowerID, uniqueLenderD)
    print('One lead {0}'.format(oneLead))
    return bankD, leadArrangerD, packageD, uniqueLenderD, packagesToKeep, baseRateD


def addToUniqueKeys(bankD, borrowerID, uniqueLenderD):
    try:
        uniqueLenderD[borrowerID] += list(set(bankD[borrowerID]))
        return uniqueLenderD
    except KeyError:
        uniqueLenderD[borrowerID] = list(set(bankD[borrowerID]))
        return uniqueLenderD

def hasFixedRate(rateList):
    if 'Fixed Rate' in rateList:
        return True
    else:
        return False

dealFrame = pd.read_csv('testdb3.csv')
# print(dealFrame[dealFrame['PackageID'] == 81113]['CompanyID'])

d = {}
for i in set(dealFrame['PackageID']):
    temp = dealFrame[dealFrame['PackageID'] == i]
    try:
        d[pd.Series.unique(temp['BorrowerCompanyID'])[0]] += list(set(temp['CompanyID']))
    except KeyError:
        d[pd.Series.unique(temp['BorrowerCompanyID'])[0]] = list(set(temp['CompanyID']))
c = 0
for i in d[9075]:
    if i == 9075:
        c +=1
print(c)
def checkIfOne(lenders, yesNoList):
    yescounter = 0
    for i in  range(len(lenders)):
        if yesNoList[i] == 'Yes':
            if yescounter == 0:
                wasLead = lenders[i]
                yescounter += 1
            elif wasLead != lenders[i]:
                return False
    return True

test = searchData('pythonTest.csv')
bank = test[0]
lead = test[1]
pack = test[2]
uniqueLend = test[3]
keep = test[4]
brD = test[5]
# print(pack)
# print(uniqueLend)
# print(brD)

print('Testing code', len(uniqueLend['9075']))
c = 0
for i in uniqueLend['9075']:
    if '9075' == i:
        c += 1
print(c)

def checkNthTimePackages(uniqueLend, n):
    count = 0
    for borrowerKey in uniqueLend:
        cnt = Counter()
        for lender in uniqueLend[borrowerKey]:
            cnt[lender] += 1
        for lender in cnt:
            if cnt[lender] == n:
                count += 1


    count1 =  0
    # for borrowerKey in uniqueLend:
    #     if hasFixedRate(brD[pack[borrowerKey]]):
    #         cnt = Counter()
    #         for lender in uniqueLend[borrowerKey]:
    #             cnt[lender] += 1
    #         for lender in cnt:
    #             if cnt[lender] == n:
    #                 count1 += 1
    # print('at least 1 fixed rate facility {0}'.format(count1))
    # return count, count1
    return count

print(checkNthTimePackages(uniqueLend, 3))
# keep = pd.DataFrame(keep)
# results = [checkNthTimePackages(uniqueLend, i) for i in range(1,15)]
# print(results)
# resultsDF = pd.DataFrame.from_records(results)
# resultsDF.to_csv('results.csv')


