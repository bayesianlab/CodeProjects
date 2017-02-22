from collections import Counter
import csv
import matplotlib.pyplot as plt
import pandas as pd
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
            # if d==10:
            #     break
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
                            lendIdBorrowerId[borrowerCompanyID] += lendAllocTup[0]
                            allocationDict[borrowerCompanyID] += lendAllocTup[1]
                            borrowerCompanyID = charToInt(row[borrowerIdCol])
                            previousPackageID = row[packageIdCol]
                            previousLender = row[lenderIdCol]
                            lenders = []
                            allocation = []
                            lenders.append(row[lenderIdCol])
                            allocation.append(row[allocationCol])
                        except KeyError:
                            lendAllocTup = searchAndDropDups(lenders, allocation)
                            lendIdBorrowerId[borrowerCompanyID] = lendAllocTup[0]
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
            lendIdBorrowerId[borrowerCompanyID] += lendAllocTup[0]
            allocationDict[borrowerCompanyID] += lendAllocTup[1]
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

lendIdBorrowerId = searchForMatch('flend.csv', 2, 4, 1, 6)
relationships = lendIdBorrowerId[0]
numberRelationships = []
for k in relationships:
    numberRelationships.append(len(relationships[k]))
lenderRelationships = np.array(numberRelationships)

f = pd.DataFrame(numberRelationships)
print(f.describe())
print(np.std(lenderRelationships))
cl = countRepeats(lendIdBorrowerId[0])

# for i, item in enumerate(lendIdBorrowerId[1]):
#     print(lendIdBorrowerId[1][item])
#     if i == 15:
#         break


        # frame = pd.DataFrame(cl, columns=['count'])
#
# frame.drop(frame.idxmax())
#
# fig, ax = plt.subplots()
# bins = [1,2, 3, 4, 5, 10]
# freqCount = pd.DataFrame(frame['count'].value_counts())
# freqCount.to_csv('freqCount.csv', ',')
#
# subset1 = frame[frame['count'] < 11]
# ax.hist(subset1['count'], histtype='stepfilled', edgecolor='black',rwidth=.8)
# ax.set_title('Borrowers with relationships less than or equal to 10')
#
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

lenderBorrower = searchForMatch('flendDroppedAllocations.csv', 2, 4, 1, 6)

moreThan50 = 0
moreThan50Repeat = 0
for i, item in enumerate(lenderBorrower[1]):
    cnt = Counter()
    numBanks = len(lenderBorrower[1][item])
    for j in range(numBanks):
        bankAlloc = lenderBorrower[1][item][j]
        if float(bankAlloc) > 50:
            bankId = lenderBorrower[0][item][j]
            # print(bankId, bankAlloc)
            # print(int(float(bankId)))
            cnt[bankId] += 1
            moreThan50 += 1
    for key in cnt:
        if cnt[key] > 1:
            moreThan50Repeat += 1

print(moreThan50)
print(moreThan50Repeat)