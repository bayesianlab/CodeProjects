__author__ = 'dillonflannery-valadez'



def addLists(list_of_lists):
    """
    Assumes all lists are same length
    :param list_of_lists:
    :return: sum across multiple lists of element i for all i.
    """
    sumOfLists = []
    x = -1
    y = -1
    for i in range(0, len(list_of_lists[0])):
        x += 1
        keep = 0
        while y < len(list_of_lists) - 1:
            y += 1
            keep += list_of_lists[y][x]
            print keep
            # raw_input()
        y = -1
        sumOfLists.append(keep)
    return sumOfLists
x = [[1,2,3], [4,5,6], [8,9,10]]
# print addLists(x)

def computeAverageAcrossLists(list_of_lists):
    if len(list_of_lists) == 1:
        return list_of_lists[0]
    else:
        sumOfLists = addLists(list_of_lists)
        numElems = len(list_of_lists)
        mean = []
        for i in sumOfLists:
            mean.append(i / float(numElems))
        return mean
# print computeAverageAcrossLists(x)
# print 13/3.0
# print 16/3.0
# print 19/3.0

x = [[1,2,3]]
# print addLists(x)
print computeAverageAcrossLists(x)
