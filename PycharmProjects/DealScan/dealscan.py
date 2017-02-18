from collections import Counter
import csv
import matplotlib.pyplot as plt
import pandas as pd
from ggplot import*
import numpy as np

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

def charToInt(char):
    return int(float(char))

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

def searchAndDropDups(lenders, allocation):
    lenLenders = len(lenders)
    k = 0
    while k < lenLenders:
        drops = dropDups(lenders, k)
        for i in reversed(drops):
            del lenders[i]
            del allocation[i]
        lenLenders = len(lenders)
        if lenLenders == 1:
            break
        k += 1
    return (lenders, allocation)




def searchForMatch(file, borrowerIdCol, lenderIdCol, packageIdCol, allocationCol):
    with open(file) as csvfile:
        scanReader = csv.reader(csvfile, delimiter=',')
        lendIdBorrowerId = {}
        allocationDict = {}
        c = 0
        d = 0
        lenders = []
        allocation = []
        previousPackageID = ''
        previousLender = ''
        borrowerCompanyID = ''
        for row in scanReader:
            if d==10:
                break
            if c == 0:
                c += 1
                d += 1
                continue
            else:
                if c == 1:
                    borrowerCompanyID = charToInt(row[borrowerIdCol])
                    previousLender = row[lenderIdCol]
                    previousPackageID = row[packageIdCol]
                    lenders.append(row[lenderIdCol])
                    allocation.append(row[allocationCol])
                else:
                    if not newPackage(previousPackageID, row[packageIdCol]):
                        lenders.append(row[lenderIdCol])
                        allocation.append(row[allocationCol])
                    else:
                        try:
                            lendAllocTup = searchAndDropDups(lenders, allocation)
                            # tempL = removeDuplicates(lendIdBorrowerId[borrowerCompanyID])
                            lendIdBorrowerId[borrowerCompanyID] = lendAllocTup[0]
                            allocationDict[borrowerCompanyID] = lendAllocTup[1]
                            borrowerCompanyID = charToInt(row[borrowerIdCol])
                            previousPackageID = row[packageIdCol]
                            previousLender = row[lenderIdCol]
                            lenders = []
                            allocation = []
                            lenders.append(row[lenderIdCol])
                            allocation.append(row[allocationCol])
                        except KeyError as e:
                            lendAllocTup = searchAndDropDups(lenders, allocation)
                            lendIdBorrowerId[borrowerCompanyID] = [lendAllocTup[0], lendAllocTup[1]]
                            allocationDict[borrowerCompanyID] = lendAllocTup[1]
                            borrowerCompanyID = charToInt(row[borrowerIdCol])
                            previousPackageID = row[packageIdCol]
                            previousLender = row[lenderIdCol]
                            lenders = []
                            allocation = []
                            lenders.append(row[lenderIdCol])
                            allocation.append(row[allocationCol])
                c += 1
                d += 1
        try:
            lendAllocTup = searchAndDropDups(lenders, allocation)
            lendIdBorrowerId[borrowerCompanyID] = lendAllocTup[0]
            allocationDict[borrowerCompanyID] = lendAllocTup[1]
        except KeyError:
            lendAllocTup = searchAndDropDups(lenders, allocation)
            lendIdBorrowerId[borrowerCompanyID] = lendAllocTup[0]
            allocationDict[borrowerCompanyID] = lendAllocTup[1]
    return (lendIdBorrowerId, allocationDict)


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

# lendIdBorrowerId = searchForMatch('flend.csv', 2, 4, 1, 6)
# cl = countRepeats(lendIdBorrowerId)
# print(cl)


# frame = pd.DataFrame(cl, columns=['count'])

# h1 = ggplot(frame, aes(x='count')) + geom_histogram(binwidth=.5) + \
#     xlab('Number of times loans repeated') + ylab('Frequency') + \
#      ggtitle('Companies that borrowed from the same lender')
# print(h1)

lendIdBorrowerId = searchForMatch('flend.csv', 2, 4, 1, 6)


# fake = pd.DataFrame({'A':[1, 5, 2,1,4, 1, 5], "B":[0, 1, 2,3,4, 5, 6] })
# print(fake)
# print(fake.drop(dropDups(fake['A'], 0)))
# fake = fake.drop(dropDups(fake['A'], 0))
# print(fake.drop(dropDups(fake['A'], 1)))

x1 = [1, 2, 3, 2, 4]
x2 = [5, 6, 3, 2, 1]
# print(searchAndDropDups(x1, x2))