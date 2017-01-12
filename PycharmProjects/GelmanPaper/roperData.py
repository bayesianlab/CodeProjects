import csv
from collections import Counter

class RoperData:

    def __init__(self, filename):
        self.filename = filename
        self.file = open(self.filename)
        for n, i in enumerate(self.file):
            pass
        self.nLines = n + 1
        self.file.close()
        print 'File %s has %s lines ' % (self.filename, self.nLines)

    def getCases(self, numCasesPerObs, colNames, begIndices, endIndices, rowOfColName):
        self.file = open(self.filename)
        totalCases = self.nLines / numCasesPerObs
        print "There are %i cases in this file." % totalCases
        rowMappedToVariableName = self.whichRows(colNames, rowOfColName)
        whatToExtractInRow = {name: indices for name, indices in zip(colNames, self.indicesToExtract(begIndices, endIndices))}
        extractedData = {name: [] for name in colNames}
        for case in range(0,totalCases):
            for c in range(0, numCasesPerObs):
                line = self.file.readline()
                try:
                    for i in rowMappedToVariableName[c]:
                        extractedData[i].append(line[whatToExtractInRow[i][0]:whatToExtractInRow[i][1]+1])
                except KeyError:
                    pass
        return extractedData
        self.file.close()

    def indicesToExtract(self, begIndices, endIndeces):
        indicesForExtraction =[]
        for i, j in zip(begIndices, endIndeces):
            indicesForExtraction.append((i,j))
        return indicesForExtraction

    def whichRows(self, names, rowWhereNameIs):
        whereColumnsAreInCase = {(c): [] for c in rowWhereNameIs}
        for index, row in enumerate(rowWhereNameIs):
            whereColumnsAreInCase[row].append(names[index])
        return whereColumnsAreInCase

    def dataToCSV(self, numCasesPerObs, colNames, begIndices, endIndices, rowOfColName, weightIndex, csvfile):
        data = self.getCases(numCasesPerObs, colNames, begIndices, endIndices, rowOfColName)
        if weightIndex != 0:
            self.decimalWeights(data, weightIndex)['weights']
            self.summaryData(data)
            data['weights'] = [float(w) for w in data['weights']]
            zd = zip(*data.values())
            with open(csvfile + '.csv', 'w') as file:
                writer = csv.writer(file, delimiter=',')
                writer.writerow(data.keys())
                writer.writerows(zd)
        else:
            self.summaryData(data)
            zd = zip(*data.values())
            with open(csvfile + '.csv', 'w') as file:
                writer = csv.writer(file, delimiter=',')
                writer.writerow(data.keys())
                writer.writerows(zd)



    def splitString(self, string, index):
        a = string[:index]
        b = string[index:]
        return ''.join([a,'.',b])

    def decimalWeights(self, casesDictionary, index):
        try:
            weights = casesDictionary['weights']
            casesDictionary['weights'] = [self.splitString(w, index) for w in weights]
            return casesDictionary
        except KeyError:
            print "No weights key, rename weights variable"
            return -1

    def summaryData(self, data):

        count = {}
        for k in data:
            cnt = Counter()
            for elem in data[k]:
                cnt[elem] += 1
            count[k] = cnt
        print count
        print




