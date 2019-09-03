__author__ = 'dillonflannery-valadez'

from MIT.ps8 import*


smallCat = {'6.00': (16, 8),
                     '1.00':   (7, 7),
                     '6.01':   (5, 3),
                     '15.01':  (9, 6)}


def loadSubjects_Tests():
    print loadSubjects(SUBJECT_FILENAME)



def smallCatalog_Tests():
    bigCatalog = loadSubjects(SUBJECT_FILENAME)
    red = reduceCatalog(bigCatalog, 15)
    print red

def find_max_dict_values_Tests():
    smallCat = {'6.00': (16, 8),''
                     '1.00':   (7, 7),
                     '6.01':   (5, 3),
                     '15.01':  (9, 6)}
    maxWork = 15
    print find_max_dict_value(smallCat, cmpValue)
    bigCat = loadSubjects(SUBJECT_FILENAME)
    print
    print find_max_dict_value(bigCat, cmpValue)

def greedyAdvisor_Tests():
    subDictionary = {'6.00': (16, 8),
                     '1.00':   (7, 7),
                     '6.01':   (5, 3),
                     '15.01':  (9, 6)}
    print greedyAdvisor(subDictionary, 15, cmpValue), "Greedy 1"
    print
    print greedyAdvisor(subDictionary, 15, cmpWork), " Greedy 2 "
    print
    print greedyAdvisor(subDictionary, 15, cmpRatio), " Greedy 3"
    print
    subjects = loadSubjects(SUBJECT_FILENAME)
    print greedyAdvisor(subjects, 15, cmpValue), "Greedy 2"
    print

def small_Dict(subjects):
    smallDictionary = {}
    i = -1
    for j in subjects:
        smallDictionary[j] = subjects[j]
        i += 1
        if i == 5:
            break
    return smallDictionary

def brute_force_time_Tests():
    subjects = loadSubjects(SUBJECT_FILENAME)
    # printSubjects(smallDictionary)
    # print bruteForceTime()
    printSubjects(bruteForceAdvisor(subjects, 4))

def calculateValue_Tests():
    vals = smallCat.values()
    print "Answer 37"
    print calculateValue([0,1,2,3], vals)

def calculateWork_Tests():
    vals = smallCat.values()
    print vals
    print calculateWork([0,1,2], vals)

def findMinIndxVals_Tests():
    vals = smallCat.values()
    print vals
    subs = [0, 1, 2]
    maxWork = 20
    print findMinIndx(subs, vals, maxWork)

def createValueList_Tests():
    valWorkTups = smallCat.values()
    subset = [0,1,2]
    print "catalog", smallCat
    print "Working subset", subset
    valueTupleList = createValueTupleList(subset, valWorkTups)

    print valueTupleList
    print createValueList(valueTupleList)

def dictionaries_for_testing():
    smallCat1 = {'6.00': (8,7),
                     '1.00':   (7, 7),
                     '6.01':   (5, 7),
                     '15.01':  (9, 7)}
    smallCat2 = {'6.00': (8,1),
                     '1.00':   (7, 1),
                     '6.01':   (5, 1),
                     '15.01':  (9, 4)}
    smallCat3 = {'6.00': (8,3),
                     '1.00':   (7, 12),
                     '6.01':   (5, 4),
                     '15.01':  (9, 10)}
    return [smallCat1, smallCat2, smallCat3]

def fastDpAdvisor_Tests():
    testableDictionaries = dictionaries_for_testing()
    dict1 = testableDictionaries[0]
    dict2 = testableDictionaries[1]
    dict3 = testableDictionaries[2]
    vals1 = dict1.values()
    vals2 = dict2.values()
    vals3 = dict3.values()
    keys1 = dict1.keys()
    keys2 = dict2.keys()
    keys3 = dict3.keys()
    print "Test 1"
    print testableDictionaries[0]
    print fastDpAdvisor(vals1, 7, [], len(vals1) - 1, {})
    for i in fastDpAdvisor(vals1, 7, [], len(vals1) - 1, {}):
            print keys1[i], vals1[i]
    print "Answer should be 15.01"
    print
    print "Test 2"
    print testableDictionaries[1]
    print fastDpAdvisor(vals2, 7, [], len(vals2) -1, {})
    for i in fastDpAdvisor(vals2, 7, [], len(vals2) -1, {}):
        print keys2[i], dict2[keys2[i]]
    print " Answer should be all courses"
    print
    print "Test 3"
    print dict3
    print fastDpAdvisor(vals3, 7, [], len(vals3) -1, {})
    for i in fastDpAdvisor(vals3, 7, [], len(vals3) -1, {}):
        print keys3[i], dict3[keys3[i]]
    print "Answer should be course 6.00 and 6.01"


def noDuplicates_Tests():
    aList = [0, 0 , 1]
    print noDuplicates(aList, 0)

def grandFinale_Test():
    print dpAdvisor(subjects, 4)
    # print subjects["6.00"]
    # print subjects["7.16"]







# Needed globals

subjects = loadSubjects(SUBJECT_FILENAME)
# print subjects
# printSubjects(subjects)



print
print  "\tTests: "

# print
# print " Small Catalog Tests: "
# # smallCatalog_Tests()
#
# print
# print " Find Max Dict Values Tests:  "
# find_max_dict_values_Tests()
# # print subjects[find_max_dict_value(subjects, cmpValue)]
# # print subjects["6.00"]
#
# print
# print " Greedy Advisor Tests: "
# greedyAdvisor_Tests()
# selected = greedyAdvisor(smallCat, 15, cmpRatio)
# printSubjects(selected)




# print "DP Advisor"

# calculateValue_Tests()
# calculateWork_Tests()
# noDuplicates_Tests()
# createValueList_Tests()
# findMinIndxVals_Tests()
# print fastMaxVal([3,2,3,4], [1,2,3,4], 3, 3, {})
# dictionaries_for_testing()
# fastDpAdvisor_Tests()

# print bruteForceAdvisor(subjects, 4)
# grandFinale_Test()

print
print " time comparison "
print bruteForceTime()
print dpTime()




