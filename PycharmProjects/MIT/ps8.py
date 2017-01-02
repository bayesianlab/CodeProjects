# 6.00 Problem Set 8
#
# Intelligent Course Advisor
#
# Name:
# Collaborators:
# Time:
#

import time
import string


SUBJECT_FILENAME = "subjects.txt"
VALUE, WORK = 0, 1

#
# Problem 1: Building A Subject Dictionary
#
def clean_file(filename):
    inputFile = open(filename)
    x = []
    for line in inputFile:
        x.append(line.split(","))
    sublist = -1
    for i in x:
        sublist += 1
        x[sublist][2] = i[2].strip("\n")
    return x


def loadSubjects(filename):
    """
    Returns a dictionary mapping subject name to (value, work), where the name
    is a string and the value and work are integers. The subject information is
    read from the file named by the string filename. Each line of the file
    contains a string of the form "name,value,work".

    returns: dictionary mapping subject name to (value, work)
    """

    # The following sample code reads lines from the specified file and prints
    # each one.
    cleaned_file = clean_file(filename)
    subject_to_valuework_dict = {}
    for sublist in cleaned_file:
        subject_to_valuework_dict[sublist[0]] = (int(sublist[1]), int(sublist[2]))
    return subject_to_valuework_dict


def printSubjects(subjects):
    """
    Prints a string containing name, value, and work of each subject in
    the dictionary of subjects and total value and work of all subjects
    """
    totalVal, totalWork = 0,0
    if len(subjects) == 0:
        return 'Empty SubjectList'
    res = 'Course\tValue\tWork\n======\t====\t=====\n'
    subNames = subjects.keys()
    subNames.sort()
    for s in subNames:
        val = subjects[s][VALUE]
        work = subjects[s][WORK]
        res = res + s + '\t' + str(val) + '\t\t' + str(work) + '\n'
        totalVal += val
        totalWork += work
    res = res + '\nTotal Value:\t' + str(totalVal) +'\n'
    res = res + 'Total Work:\t' + str(totalWork) + '\n'
    print res

# Help functions, get a small catalog to meet student demands #

def reduceCatalog(bigCatalog, maxWork):
    """
    Reduce the catalog down to acceptable classes based upon
    the max amount of work a student is willing to do.
    :param bigCatalog: dictionary from above ->  tuple (value, work)
    :param maxWork: Amount of work willing to do,
    :return: smallCatalog, dicitonary
    """
    # tuples = bigCatalog.values()
    reducedCatalog = {}
    for course in bigCatalog:
        if bigCatalog[course][WORK] <= 15:
            reducedCatalog[course] = bigCatalog[course]
    return reducedCatalog

###

def cmpValue(subInfo1, subInfo2):
    """
    Returns True if value in (value, work) tuple subInfo1 is GREATER than
    value in (value, work) tuple in subInfo2
    """
    val1 = subInfo1[VALUE]
    val2 = subInfo2[VALUE]
    return  val1 > val2

def cmpWork(subInfo1, subInfo2):
    """
    Returns True if work in (value, work) tuple subInfo1 is LESS than than work
    in (value, work) tuple in subInfo2
    """
    work1 = subInfo1[WORK]
    work2 = subInfo2[WORK]
    return  work1 < work2

def cmpRatio(subInfo1, subInfo2):
    """
    Returns True if value/work in (value, work) tuple subInfo1 is 
    GREATER than value/work in (value, work) tuple in subInfo2
    """
    val1 = subInfo1[VALUE]
    val2 = subInfo2[VALUE]
    work1 = subInfo1[WORK]
    work2 = subInfo2[WORK]
    return float(val1) / work1 > float(val2) / work2

#
# Problem 2: Subject Selection By Greedy Optimization
#
def find_max_dict_value(smallCat, comparator):
    key_list = smallCat.keys()
    # print key_list, " key list"
    max_key_indx = 0
    current_max = smallCat[key_list[0]]

    for key in range(1, len(key_list)):
        subinfo2 = smallCat[key_list[key]]
        # print current_max, subinfo2, "cm, sub2"
        compVal = comparator(current_max, subinfo2)
        if compVal == False:
            # print "False", current_max, subinfo2
            current_max = subinfo2
            max_key_indx = key
    return key_list[max_key_indx]

def greedyAdvisor(subjects, maxWork, comparator):
    """
    Returns a dictionary mapping subject name to (value, work) which includes
    subjects selected by the algorithm, such that the total work of subjects in
    the dictionary is not greater than maxWork.  The subjects are chosen using
    a greedy algorithm.  The subjects dictionary should not be mutated.

    subjects: dictionary mapping subject name to (value, work)
    maxWork: int >= 0
    comparator: function taking two tuples and returning a bool
    returns: dictionary mapping subject name to (value, work)
    """
    sumHours = 0
    smallCat = reduceCatalog(subjects, maxWork)
    copyCat = smallCat.copy()
    iters = -1
    course_load = {}
    acceptable_load = True
    while acceptable_load == True:
        iters += 1
        key = find_max_dict_value(copyCat, comparator)
        work_hours = smallCat[key][WORK]
        sumHours += work_hours
        if sumHours > 15:
            acceptable_load = False
        else:
            course_load[key] = smallCat[key]
            del copyCat[key]
    return course_load



def bruteForceAdvisor(subjects, maxWork):
    """
    Returns a dictionary mapping subject name to (value, work), which
    represents the globally optimal selection of subjects using a brute force
    algorithm.

    subjects: dictionary mapping subject name to (value, work)
    maxWork: int >= 0
    returns: dictionary mapping subject name to (value, work)
    """
    nameList = subjects.keys()
    tupleList = subjects.values()
    bestSubset, bestSubsetValue = \
            bruteForceAdvisorHelper(tupleList, maxWork, 0, None, None, [], 0, 0)
    outputSubjects = {}
    for i in bestSubset:
        outputSubjects[nameList[i]] = tupleList[i]
    return outputSubjects

def bruteForceAdvisorHelper(subjects, maxWork, i, bestSubset, bestSubsetValue,
                            subset, subsetValue, subsetWork):
    # Hit the end of the list.
    if i >= len(subjects):
        if bestSubset == None or subsetValue > bestSubsetValue:
            # Found a new best.
            return subset[:], subsetValue
        else:
            # Keep the current best.
            return bestSubset, bestSubsetValue
    else:
        s = subjects[i]
        # Try including subjects[i] in the current working subset.
        if subsetWork + s[WORK] <= maxWork:
            subset.append(i)
            bestSubset, bestSubsetValue = bruteForceAdvisorHelper(subjects,
                    maxWork, i+1, bestSubset, bestSubsetValue, subset,
                    subsetValue + s[VALUE], subsetWork + s[WORK])
            subset.pop()
        bestSubset, bestSubsetValue = bruteForceAdvisorHelper(subjects,
                maxWork, i+1, bestSubset, bestSubsetValue, subset,
                subsetValue, subsetWork)
        return bestSubset, bestSubsetValue

#
# Problem 3: Subject Selection By Brute Force
#
def bruteForceTime():
    """
    Runs tests on bruteForceAdvisor and measures the time required to compute
    an answer.
    """
    # TODO...
    subjects = loadSubjects(SUBJECT_FILENAME)
    start_time = time.time()
    bruteForceAdvisor(subjects, 9)
    end_time = time.time()
    return end_time - start_time

# Problem 3 Observations
# ======================
#
# TODO: write here your observations regarding bruteForceTime's performance
# Takes forever anything greater than 6.

#
# Problem 4: Subject Selection By Dynamic Programming

def calculateValue( subset, valueWorkPairs):
    value = 0
    for i in subset:
        value += valueWorkPairs[i][0]
    return value
#
# def calculateWork(subset, valueWorkPairs):
#     work = 0
#     for i in subset:
#         work += valueWorkPairs[i][1]
#     return work

# def createValueTupleList(subset, valueWorkPairs):
#     valueList = []
#     x = -1
#     for i in subset:
#         valueList.append((valueWorkPairs[i][0], i))
#     return valueList
#
# def createValueList(valueTupleList):
#     valueList = []
#     for i in valueTupleList:
#         valueList += [i[0]]
#     return valueList
#
# def findMinIndx(subset, valueWorkPairs, maximumWork):
#     totalWork = calculateWork(subset, valueWorkPairs)
#     while totalWork >= maximumWork:
#         valList = createValueList(createValueTupleList(subset, valueWorkPairs))
#         leastValue = valList.index(min(valList))
#         subset.pop(leastValue)
#         totalWork = calculateWork(subset,valueWorkPairs)
#     return subset


def noDuplicates(aList, elem):
    duplicateCounter = 0
    for i in aList:
        if i == elem:
            duplicateCounter += 1
            if duplicateCounter == 2:
                aList.remove(elem)
                return aList
            else:
                pass
    else:
        return aList

def returnHighestValueList(list1, list2, valueWorkPairs):
    val1 = calculateValue(list1, valueWorkPairs)
    val2 = calculateValue(list2, valueWorkPairs)
    if val1 > val2:
        return list1
    else:
        return list2

def fastDpAdvisor(valueWorkPairs, maximumWork, subset, i,  memo):
    try:
        return memo[(i, maximumWork)]
    except KeyError:
        if i == 0:
            if valueWorkPairs[i][1] <= maximumWork:
                subset.append(i)
                subset = noDuplicates(subset, i)
                memo[(i, maximumWork)] = subset
                return subset
            else:
                if i in subset:
                    subset.pop(i)
                    memo[(i, maximumWork)] = subset
                    return subset
                else:
                    memo[(i, maximumWork)] = subset
                    return subset
        withoutCourse = fastDpAdvisor(valueWorkPairs, maximumWork, subset, i - 1, memo)
        if valueWorkPairs[i][1] > maximumWork:
            memo[(i, maximumWork)] = withoutCourse
            return withoutCourse
        else:
            withCourse = [i] + fastDpAdvisor(valueWorkPairs,
                                              maximumWork - valueWorkPairs[i][1], subset, i - 1, memo)
        result = returnHighestValueList(withCourse, withoutCourse, valueWorkPairs)
        memo[(i, maximumWork)] = result
        return result




def dpAdvisor(subjects, maxWork):
    """
    Returns a dictionary mapping subject name to (value, work) that contains a
    set of subjects that provides the maximum value without exceeding maxWork.

    subjects: dictionary mapping subject name to (value, work)
    maxWork: int >= 0
    returns: dictionary mapping subject name to (value, work)
    """
    valueWorkPairs = subjects.values()
    subjectCourseNames = subjects.keys()
    maxIterations = len(valueWorkPairs) -1
    memo = {}
    subset = []
    maximzedValue = fastDpAdvisor(valueWorkPairs, maxWork, subset, maxIterations, memo )
    resultKeys = []
    resultValues = []
    for name in maximzedValue:
        resultKeys += [subjectCourseNames[name]]
    for pair in maximzedValue:
        resultValues += [valueWorkPairs[pair]]
    resultList = []
    for i, j in zip(resultKeys, resultValues):
        resultList += [(i,j)]
    return dict(resultList)




# Problem 5: Performance Comparison
#
def dpTime():
    """
    Runs tests on dpAdvisor and measures the time required to compute an
    answer.
    """
    # TODO...
    subjects = loadSubjects(SUBJECT_FILENAME)
    maxWork = 9
    startTime = time.time()
    dpAdvisor(subjects, maxWork)
    endTime = time.time()
    return endTime - startTime


# Problem 5 Observations
# ======================
#
# TODO: write here your observations regarding dpAdvisor's performance and
# how its performance compares to that of bruteForceAdvisor.
